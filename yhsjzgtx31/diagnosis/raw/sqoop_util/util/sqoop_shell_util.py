# -*- coding: utf-8 -*-
import ConfigParser

from mysql_util import Mysql
from oracle_util import Oracle
from path_util import *
from sqlserver_util import SqlServer


class SqoopShellUtil(object):
    __shell_head = "#!/bin/bash\nsource ../../config.sh\n\nexec_dir dbname_shell\n"

    __shell_foot = "fn_log 'finish'\nrm -rf *.java"

    __sqoop_create_database = 'hive -e "create database if not exists %s;"'

    __mysql_connect_path = "--connect 'jdbc:mysql://%s:%s/%s?useUnicode=true&characterEncoding=utf-8" \
                           "&zeroDateTimeBehavior=convertToNull&transformedBitIsBoolean=true&tinyInt1isBit=false' " \
                           "--username %s --password %s --driver com.mysql.jdbc.Driver"

    __oracle_connect_path_sid = "--connect jdbc:oracle:thin:@%s:%s:%s --username %s --password %s "
    __oracle_connect_path_server_name = "--connect jdbc:oracle:thin:@//%s:%s/%s --username %s --password %s "

    __sqlserver_connect_path = "--connect 'jdbc:sqlserver://%s:%s;username=%s;password=%s;database=%s'" \
                               " --driver com.microsoft.sqlserver.jdbc.SQLServerDriver"

    __create_table_shell = "sqoop create-hive-table %s --table %s  --hive-table %s "

    __external_table_shell = "hive -e \"alter table %s set TBLPROPERTIES ('EXTERNAL'='TRUE');\""

    __location_table_shell = "hive -e \"alter table %s set location 'hdfs:/%s';\""

    __import_table_shell = "sqoop import --hive-import %s --table %s --hive-table %s -m 1 --hive-overwrite " \
                           "--input-null-string '\\\\N' --input-null-non-string '\\\\N' --hive-drop-import-delims " \
                           "--null-string '\\\\N' --null-non-string '\\\\N' --fields-terminated-by '\\0001' "

    __append_table_shell = "%s\nsqoop import --hive-import %s --table %s --hive-table %s -m 10 " \
                           "--input-null-string '\\\\N' --input-null-non-string '\\\\N' " \
                           "--null-string '\\\\N' --null-non-string '\\\\N' --hive-drop-import-delims " \
                           "--fields-terminated-by '\\0001' --incremental %s --check-column %s --last-value ${MAX_V};"

    @staticmethod
    def show_big_table(config_file, section):
        db_type = SqoopShellUtil.get_db_type(config_file, section)
        big_table = None
        if db_type == 'mysql':
            database = Mysql(section, config_file)
            sql = "select table_name, table_rows from tables where TABLE_SCHEMA = '%s' and table_rows>1000000" \
                  % database.db
            database.getOne("use information_schema;")
            big_table = database.getAll(sql)
            database._exeCute("use " + database.db)
        elif db_type == 'oracle':
            database = Oracle(section, config_file)
            sql = "select TABLE_NAME from all_tables where owner='%s'" % database.db
            all_table = database.getAll(sql)
            sql = "select VIEW_NAME from all_views where owner='%s'" % database.db
            all_view = database.getAll(sql)
            big_table = {}
            for table in all_table:
                table_name = table[0]
                sql = "select count(1) from %s.%s " % (database.db, table_name)
                count = database.getOne(sql)[0]
                if count > 1000000:
                    big_table[table_name] = count
            for table in all_view:
                table_name = table[0]
                sql = "select count(1) from %s.%s " % (database.db, table_name)
                count = database.getOne(sql)[0]
                if count > 1000000:
                    big_table[table_name] = count
            big_table = sorted(big_table.items(), key=lambda item: item[1], reverse=True)
        elif db_type == 'sqlserver':
            database = SqlServer(section, config_file)
            sql = "SELECT a.name,b.rows FROM sysobjects a INNER JOIN sysindexes b ON a.id=b.id " \
                  "WHERE b.indid IN(0,1) AND a.XType in ('v','u') AND b.rows > 1000000 "
            big_table = database.getAll(sql)
            sql = "select Name from SysObjects where XType = 'v'"
            v_table = database.getAll(sql)
            print v_table, '为视图,无法查询数据量'
        print big_table

    @staticmethod
    def get_db_type(config_file, section):
        config = ConfigParser.ConfigParser()
        config.read(config_file)
        return config.get(section, "db_type")

    @staticmethod
    def get_database(config_file, section, db_type):
        database = None
        if db_type == 'mysql':
            database = Mysql(section, config_file)
        elif db_type == 'oracle':
            database = Oracle(section, config_file)
        elif db_type == 'sqlserver':
            database = SqlServer(section, config_file)
        return database

    @staticmethod
    def get_all_tables(database, db_type):
        all_table = None
        if db_type == 'mysql':
            all_table = database.getAll("show tables")
        elif db_type == 'oracle':
            sql = "select TABLE_NAME from all_tables where owner='%s' ORDER BY TABLE_NAME" % database.db
            all_table_1 = database.getAll(sql)
            sql = "select VIEW_NAME from all_views where owner='%s' ORDER BY VIEW_NAME" % database.db
            all_table_2 = database.getAll(sql)
            all_table = all_table_1 + all_table_2
        elif db_type == 'sqlserver':
            sql = "select Name from SysObjects where XType in ('v','u') ORDER BY Name"
            all_table = database.getAll(sql)
        return all_table

    @staticmethod
    def create_table_shell(config_file, section):
        db_type = SqoopShellUtil.get_db_type(config_file, section)
        database = SqoopShellUtil.get_database(config_file, section, db_type)
        all_table = SqoopShellUtil.get_all_tables(database, db_type)

        sqoop_connect = SqoopShellUtil._make_db_connect(database, db_type)
        shell_list = [SqoopShellUtil._make_shell_head(database.prefix, 'create_table'), '', '',
                      SqoopShellUtil._make_create_database(), '', '']

        for table in all_table:
            table_name = None
            if db_type == 'mysql':
                table_name = table.values()[0]
            elif db_type == 'oracle' or db_type == 'sqlserver':
                table_name = table[0]

            hive_table_name = SqoopShellUtil._make_hive_table_name(database.prefix, table_name)

            if db_type == 'oracle':
                table_name = database.db + '.' + table_name

            table_name = table_name.replace("$", "\$")

            shell_list.append(SqoopShellUtil._make_create_table(sqoop_connect, table_name, hive_table_name))
            shell_list.append(SqoopShellUtil._log_create_table(hive_table_name))

            shell_list.append(SqoopShellUtil._make_external_table(hive_table_name))
            shell_list.append(SqoopShellUtil._log_external_table(hive_table_name))

            location = SqoopShellUtil._make_hive_location(hive_table_name)
            shell_list.append(SqoopShellUtil._make_location_table(hive_table_name, location))
            shell_list.append(SqoopShellUtil._log_location_table(hive_table_name))

            shell_list.append('')
            shell_list.append('')

        shell_list.append(SqoopShellUtil.__shell_foot)
        file_path = cur_file_parent_dir() + '/raw_%s/create/%s_create_table.sh' % (database.prefix, database.prefix)
        SqoopShellUtil._write_file(shell_list, file_path)

    @staticmethod
    def sqoop_import_shell(config_file, section, incremental_tables):
        db_type = SqoopShellUtil.get_db_type(config_file, section)
        database = SqoopShellUtil.get_database(config_file, section, db_type)
        all_table = SqoopShellUtil.get_all_tables(database, db_type)
        sqoop_connect = SqoopShellUtil._make_db_connect(database, db_type)
        shell_list = [SqoopShellUtil._make_shell_head(database.prefix, 'sqoop_import'), '', '']
        for table in all_table:
            table_name = None
            if db_type == 'mysql':
                table_name = table.values()[0]
            elif db_type == 'oracle' or db_type == 'sqlserver':
                table_name = table[0]

            hive_table_name = SqoopShellUtil._make_hive_table_name(database.prefix, table_name)
            if db_type == 'oracle':
                table_name = database.db + '.' + table_name

            table_name = table_name.replace("$", "\$")

            if table_name not in map(str, incremental_tables):

                shell_list.append(SqoopShellUtil._make_import_table(sqoop_connect, table_name, hive_table_name))
                shell_list.append(SqoopShellUtil._log_import_table(hive_table_name))

                shell_list.append('')
                shell_list.append('')
            else:
                incremental_tables_str = map(str, incremental_tables)
                incremental = incremental_tables[incremental_tables_str.index(table_name)]

                shell_list.append(
                    SqoopShellUtil._make_append_table(sqoop_connect, table_name, hive_table_name, incremental))
                shell_list.append(SqoopShellUtil._log_append_table(hive_table_name))

                shell_list.append('')
                shell_list.append('')

        shell_list.append(SqoopShellUtil.__shell_foot)
        file_path = cur_file_parent_dir() + '/raw_%s/import/%s_sqoop_import.sh' % (database.prefix, database.prefix)
        SqoopShellUtil._write_file(shell_list, file_path)

    @staticmethod
    def _make_shell_head(prefix, shell):
        return SqoopShellUtil.__shell_head.replace('dbname', prefix).replace('shell', shell)

    @staticmethod
    def _make_hive_database():
        return 'raw'

    @staticmethod
    def _make_hive_location(hive_table_name):
        if hive_table_name.__contains__('.'):
            hive_table_name = hive_table_name.split('.')[1]
        return SqoopShellUtil._make_hive_database() + '/' + hive_table_name

    @staticmethod
    def _make_hive_table_name(prefix, table_name):
        name = SqoopShellUtil._make_hive_database() + '.' + prefix + "_" + table_name
        return name.replace("-", "_").replace("$", "\$")

    @staticmethod
    def _make_db_connect(database, db_type):
        if db_type == 'mysql':
            return SqoopShellUtil.__mysql_connect_path % (
                database.host, database.port, database.db, database.user, database.passwd)
        elif db_type == 'oracle':
            sid_type = database.type
            if sid_type == 'servername':
                connect_path = SqoopShellUtil.__oracle_connect_path_server_name
            else:
                connect_path = SqoopShellUtil.__oracle_connect_path_sid
            return connect_path % (database.host, database.port, database.sid, database.user, database.passwd)
        elif db_type == 'sqlserver':
            return SqoopShellUtil.__sqlserver_connect_path % (
                database.host, database.port, database.user, database.passwd, database.db)

    @staticmethod
    def _make_create_database():
        return SqoopShellUtil.__sqoop_create_database % SqoopShellUtil._make_hive_database()

    @staticmethod
    def _make_create_table(sqoop_connect, table_name, hive_table_name):
        return SqoopShellUtil.__create_table_shell % (sqoop_connect, table_name, hive_table_name)

    @staticmethod
    def _make_external_table(hive_table_name):
        return SqoopShellUtil.__external_table_shell % hive_table_name

    @staticmethod
    def _make_location_table(hive_table_name, location):
        return SqoopShellUtil.__location_table_shell % (hive_table_name, location)

    @staticmethod
    def _make_import_table(sqoop_connect, table_name, hive_table_name):
        return SqoopShellUtil.__import_table_shell % (sqoop_connect, table_name, hive_table_name)

    @staticmethod
    def _make_append_table(sqoop_connect, table_name, hive_table_name, incremental):
        sql = "MAX_V=`hive -e \"select max(%s) from %s\"`" % (incremental.column, hive_table_name)
        return SqoopShellUtil.__append_table_shell % (sql, sqoop_connect, table_name, hive_table_name, incremental.mode,
                                                      incremental.column)

    @staticmethod
    def _log(msg):
        return "fn_log '%s'" % msg

    @classmethod
    def _log_create_table(cls, table_name):
        return cls._log('sqoop create table[%s]' % table_name)

    @classmethod
    def _log_external_table(cls, table_name):
        return cls._log('hive change table[%s] external' % table_name)

    @classmethod
    def _log_location_table(cls, table_name):
        return cls._log('hive change table[%s] location' % table_name)

    @classmethod
    def _log_import_table(cls, table_name):
        return cls._log('sqoop import table[%s]' % table_name)

    @classmethod
    def _log_append_table(cls, table_name):
        return cls._log('sqoop import table[%s] append maxvalue:${MAX_V}' % table_name)

    @staticmethod
    def _write_file(shell_list, file_path):
        path = os.path.dirname(file_path)
        is_exists = os.path.exists(path)
        if not is_exists:
            os.makedirs(path)
        content = '\n'.join(shell_list)
        print content
        shell_file = open(file_path, 'w')
        shell_file.writelines(content)
        shell_file.close()


class Incremental(object):
    def __init__(self, table, mode, column):
        self._table = table
        self._mode = mode
        self._column = column

    def __repr__(self):
        return self._table

    @property
    def table(self):
        return self._table

    @property
    def mode(self):
        return self._mode

    @property
    def column(self):
        return self._column
