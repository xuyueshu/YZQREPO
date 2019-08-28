#! /usr/bin/env python
# -*-coding:utf-8-*-
import sys

import pyhs2

reload(sys)
sys.setdefaultencoding('utf-8')


class HiveClient:
    def __init__(self, db_host, user, password, database, port=10000, authMechanism="LDAP"):
        """
        create connection to hive server2
        """
        self.conn = pyhs2.connect(host=db_host,
                                  port=port,
                                  authMechanism=authMechanism,
                                  user=user,
                                  password=password,
                                  database=database
                                  )

    def query(self, sql):
        with self.conn.cursor() as cursor:
            cursor.execute(sql)

            return cursor.fetch()

    def close(self):
        self.conn.close()
