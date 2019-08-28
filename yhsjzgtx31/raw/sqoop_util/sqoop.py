# !/usr/bin/python
# -*- coding:utf-8 -*-
from util import *

conf_file = path_util.cur_file_dir() + '/config.conf'


def make_shell(section):
    incremental_tables = []
    SqoopShellUtil.show_big_table(conf_file, section)
    SqoopShellUtil.create_table_shell(conf_file, section)
    SqoopShellUtil.sqoop_import_shell(conf_file, section, incremental_tables)


if __name__ == "__main__":
    make_shell('tushu_sqlserver')
    make_shell('jiaowu_oracle')
    make_shell('wired_mysql')
