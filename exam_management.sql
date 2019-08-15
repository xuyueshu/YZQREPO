/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50534
 Source Host           : localhost:3306
 Source Schema         : exam_management

 Target Server Type    : MySQL
 Target Server Version : 50534
 File Encoding         : 65001

 Date: 02/03/2019 14:55:53
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Table structure for clazz
-- ----------------------------
DROP TABLE IF EXISTS `clazz`;
CREATE TABLE `clazz`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `gradeid` int(11) NULL DEFAULT NULL,
  `leaderTeacherId` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `gid_clazz_FK`(`gradeid`) USING BTREE,
  CONSTRAINT `gradeid_clazz_FK` FOREIGN KEY (`gradeid`) REFERENCES `grade` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of clazz
-- ----------------------------
INSERT INTO `clazz` VALUES (1, '高一（1）班', 1, 1);
INSERT INTO `clazz` VALUES (2, '高一（2）班', 1, 7);
INSERT INTO `clazz` VALUES (3, '高一（3）班', 1, 4);
INSERT INTO `clazz` VALUES (4, '高二（1）班', 2, 5);
INSERT INTO `clazz` VALUES (5, '高二（2）班', 2, 11);
INSERT INTO `clazz` VALUES (6, '高二（3）班', 2, 8);
INSERT INTO `clazz` VALUES (7, '高三（1）班', 3, 9);
INSERT INTO `clazz` VALUES (8, '高三（2）班', 3, 6);
INSERT INTO `clazz` VALUES (9, '高三（3）班', 3, 12);

-- ----------------------------
-- Table structure for course
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES (1, '语文');
INSERT INTO `course` VALUES (2, '数学');
INSERT INTO `course` VALUES (3, '外语');
INSERT INTO `course` VALUES (4, '物理');
INSERT INTO `course` VALUES (5, '化学');
INSERT INTO `course` VALUES (6, '生物');

-- ----------------------------
-- Table structure for escore
-- ----------------------------
DROP TABLE IF EXISTS `escore`;
CREATE TABLE `escore`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `examid` int(11) NULL DEFAULT NULL,
  `clazzid` int(11) NULL DEFAULT NULL,
  `studentid` int(11) NULL DEFAULT NULL,
  `gradeid` int(11) NULL DEFAULT NULL,
  `courseid` int(11) NULL DEFAULT NULL,
  `score` int(10) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `eid_escore_FK`(`examid`) USING BTREE,
  INDEX `sid_escore_FK`(`studentid`) USING BTREE,
  INDEX `clazzid_escore_FK`(`clazzid`) USING BTREE,
  INDEX `courseid_escore_FK`(`courseid`) USING BTREE,
  INDEX `gradeid_escore_FK`(`gradeid`) USING BTREE,
  CONSTRAINT `clazzid_escore_FK` FOREIGN KEY (`clazzid`) REFERENCES `clazz` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `courseid_escore_FK` FOREIGN KEY (`courseid`) REFERENCES `grade_course` (`courseid`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `examid_escore_FK` FOREIGN KEY (`examid`) REFERENCES `exam` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gradeid_escore_FK` FOREIGN KEY (`gradeid`) REFERENCES `grade_course` (`gradeid`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `studentid_escore_FK` FOREIGN KEY (`studentid`) REFERENCES `student` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 75 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of escore
-- ----------------------------
INSERT INTO `escore` VALUES (1, 1, 1, 1, 1, 1, 80);
INSERT INTO `escore` VALUES (2, 2, 1, 1, 1, 2, 88);
INSERT INTO `escore` VALUES (3, 3, 1, 1, 1, 3, 76);
INSERT INTO `escore` VALUES (4, 4, 1, 1, 1, 4, 78);
INSERT INTO `escore` VALUES (5, 5, 1, 1, 1, 5, 98);
INSERT INTO `escore` VALUES (6, 6, 1, 1, 1, 6, 67);
INSERT INTO `escore` VALUES (7, 7, 4, 3, 2, 1, 60);
INSERT INTO `escore` VALUES (8, 8, 4, 3, 2, 2, 67);
INSERT INTO `escore` VALUES (9, 9, 4, 3, 2, 3, 87);
INSERT INTO `escore` VALUES (10, 10, 4, 3, 2, 4, 92);
INSERT INTO `escore` VALUES (11, 11, 4, 3, 2, 5, 67);
INSERT INTO `escore` VALUES (12, 12, 4, 3, 2, 6, 87);
INSERT INTO `escore` VALUES (13, 13, 7, 4, 3, 1, 78);
INSERT INTO `escore` VALUES (14, 14, 7, 4, 3, 2, 65);
INSERT INTO `escore` VALUES (15, 15, 7, 4, 3, 3, 77);
INSERT INTO `escore` VALUES (16, 16, 7, 4, 3, 4, 87);
INSERT INTO `escore` VALUES (17, 17, 7, 4, 3, 5, 68);
INSERT INTO `escore` VALUES (18, 18, 7, 4, 3, 6, 88);
INSERT INTO `escore` VALUES (19, 7, 5, 5, 2, 1, 66);
INSERT INTO `escore` VALUES (20, 8, 5, 5, 2, 2, 45);
INSERT INTO `escore` VALUES (21, 9, 5, 5, 2, 3, 73);
INSERT INTO `escore` VALUES (22, 10, 5, 5, 2, 4, 58);
INSERT INTO `escore` VALUES (23, 11, 5, 5, 2, 5, 77);
INSERT INTO `escore` VALUES (24, 12, 5, 5, 2, 6, 62);
INSERT INTO `escore` VALUES (25, 1, 1, 6, 1, 1, 80);
INSERT INTO `escore` VALUES (28, 7, 5, 9, 2, 1, 50);
INSERT INTO `escore` VALUES (29, 7, 5, 10, 2, 1, 99);
INSERT INTO `escore` VALUES (30, 7, 5, 11, 2, 1, 87);
INSERT INTO `escore` VALUES (33, 7, 5, 12, 2, 1, 70);
INSERT INTO `escore` VALUES (34, 19, 1, 1, 1, 1, 60);
INSERT INTO `escore` VALUES (35, 20, 1, 1, 1, 2, 70);
INSERT INTO `escore` VALUES (36, 21, 1, 1, 1, 3, 80);
INSERT INTO `escore` VALUES (37, 22, 1, 1, 1, 4, 90);
INSERT INTO `escore` VALUES (38, 23, 1, 1, 1, 5, 91);
INSERT INTO `escore` VALUES (39, 24, 1, 1, 1, 6, 92);
INSERT INTO `escore` VALUES (40, 7, 5, 13, 2, 1, 100);
INSERT INTO `escore` VALUES (41, 7, 5, 14, 2, 1, 88);
INSERT INTO `escore` VALUES (42, 16, 9, 35, 3, 4, 88);
INSERT INTO `escore` VALUES (43, 8, 5, 9, 2, 2, 60);
INSERT INTO `escore` VALUES (44, 8, 5, 10, 2, 2, 80);
INSERT INTO `escore` VALUES (45, 8, 5, 11, 2, 2, 80);
INSERT INTO `escore` VALUES (46, 8, 5, 12, 2, 2, 77);
INSERT INTO `escore` VALUES (47, 8, 5, 13, 2, 2, 88);
INSERT INTO `escore` VALUES (48, 4, 1, 6, 1, 4, 60);
INSERT INTO `escore` VALUES (49, 4, 1, 16, 1, 4, 90);
INSERT INTO `escore` VALUES (50, 4, 2, 8, 1, 4, 80);
INSERT INTO `escore` VALUES (51, 4, 2, 18, 1, 4, 77);
INSERT INTO `escore` VALUES (52, 4, 2, 19, 1, 4, 68);
INSERT INTO `escore` VALUES (53, 5, 1, 6, 1, 5, 58);
INSERT INTO `escore` VALUES (54, 5, 1, 16, 1, 5, 75);
INSERT INTO `escore` VALUES (55, 5, 1, 17, 1, 5, 69);
INSERT INTO `escore` VALUES (56, 3, 1, 6, 1, 3, 88);
INSERT INTO `escore` VALUES (57, 3, 1, 16, 1, 3, 74);
INSERT INTO `escore` VALUES (58, 3, 1, 17, 1, 3, 66);
INSERT INTO `escore` VALUES (59, 2, 1, 6, 1, 2, 78);
INSERT INTO `escore` VALUES (60, 2, 1, 16, 1, 2, 98);
INSERT INTO `escore` VALUES (61, 2, 1, 17, 1, 2, 81);
INSERT INTO `escore` VALUES (62, 6, 1, 6, 1, 6, 72);
INSERT INTO `escore` VALUES (63, 6, 1, 16, 1, 6, 88);
INSERT INTO `escore` VALUES (64, 6, 1, 17, 1, 6, 59);
INSERT INTO `escore` VALUES (65, 1, 1, 16, 1, 1, 67);
INSERT INTO `escore` VALUES (66, 1, 1, 17, 1, 1, 73);
INSERT INTO `escore` VALUES (67, 4, 1, 17, 1, 4, 88);
INSERT INTO `escore` VALUES (68, 1, 2, 8, 1, 1, 80);
INSERT INTO `escore` VALUES (69, 15, 7, 30, 3, 3, 66);
INSERT INTO `escore` VALUES (70, 15, 7, 31, 3, 3, 70);
INSERT INTO `escore` VALUES (71, 3, 2, 8, 1, 3, 98);
INSERT INTO `escore` VALUES (72, 21, 2, 8, 1, 3, 80);
INSERT INTO `escore` VALUES (73, 3, 2, 18, 1, 3, 36);
INSERT INTO `escore` VALUES (74, 1, 2, 18, 1, 1, 98);

-- ----------------------------
-- Table structure for exam
-- ----------------------------
DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `time` date NULL DEFAULT NULL,
  `remark` varchar(200) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `type` tinyint(2) NULL DEFAULT 1,
  `gradeid` int(11) NULL DEFAULT NULL,
  `courseid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `gid_exam_FK`(`gradeid`) USING BTREE,
  CONSTRAINT `gradeid_exam_FK` FOREIGN KEY (`gradeid`) REFERENCES `grade` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of exam
-- ----------------------------
INSERT INTO `exam` VALUES (1, '高一月考语文', '2018-03-01', NULL, 1, 1, 1);
INSERT INTO `exam` VALUES (2, '高一月考数学', '2018-03-01', NULL, 1, 1, 2);
INSERT INTO `exam` VALUES (3, '高一月考外语', '2018-03-01', NULL, 1, 1, 3);
INSERT INTO `exam` VALUES (4, '高一月考物理', '2018-03-01', NULL, 1, 1, 4);
INSERT INTO `exam` VALUES (5, '高一月考化学', '2018-03-01', NULL, 1, 1, 5);
INSERT INTO `exam` VALUES (6, '高一月考生物', '2018-03-01', NULL, 1, 1, 6);
INSERT INTO `exam` VALUES (7, '高二月考语文', '2018-03-05', NULL, 1, 2, 1);
INSERT INTO `exam` VALUES (8, '高二月考数学', '2018-03-05', NULL, 1, 2, 2);
INSERT INTO `exam` VALUES (9, '高二月考外语', '2018-03-05', NULL, 1, 2, 3);
INSERT INTO `exam` VALUES (10, '高二月考物理', '2018-03-05', NULL, 1, 2, 4);
INSERT INTO `exam` VALUES (11, '高二月考化学', '2018-03-05', NULL, 1, 2, 5);
INSERT INTO `exam` VALUES (12, '高二月考生物', '2018-03-05', NULL, 1, 2, 6);
INSERT INTO `exam` VALUES (13, '高三月考语文', '2018-03-08', NULL, 1, 3, 1);
INSERT INTO `exam` VALUES (14, '高三月考数学', '2018-03-08', NULL, 1, 3, 2);
INSERT INTO `exam` VALUES (15, '高三月考外语', '2018-03-08', NULL, 1, 3, 3);
INSERT INTO `exam` VALUES (16, '高三月考物理', '2018-03-08', NULL, 1, 3, 4);
INSERT INTO `exam` VALUES (17, '高三月考化学', '2018-03-08', NULL, 1, 3, 5);
INSERT INTO `exam` VALUES (18, '高三月考生物', '2018-03-08', NULL, 1, 3, 6);
INSERT INTO `exam` VALUES (19, '高一月考语文', '2018-04-01', NULL, 2, 1, 1);
INSERT INTO `exam` VALUES (20, '高一月考数学', '2018-04-01', NULL, 2, 1, 2);
INSERT INTO `exam` VALUES (21, '高一月考外语', '2018-04-01', NULL, 2, 1, 3);
INSERT INTO `exam` VALUES (22, '高一月考物理', '2018-04-01', NULL, 2, 1, 4);
INSERT INTO `exam` VALUES (23, '高一月考化学', '2018-04-01', NULL, 2, 1, 5);
INSERT INTO `exam` VALUES (24, '高一月考生物', '2018-04-01', NULL, 2, 1, 6);
INSERT INTO `exam` VALUES (25, '高二月考语文', '2018-04-05', NULL, 2, 2, 1);
INSERT INTO `exam` VALUES (26, '高二月考数学', '2018-04-05', NULL, 2, 2, 2);
INSERT INTO `exam` VALUES (27, '高二月考外语', '2018-04-05', NULL, 2, 2, 3);
INSERT INTO `exam` VALUES (28, '高二月考物理', '2018-04-05', NULL, 2, 2, 4);
INSERT INTO `exam` VALUES (29, '高二月考化学', '2018-04-05', NULL, 2, 2, 5);
INSERT INTO `exam` VALUES (30, '高二月考生物', '2018-04-05', NULL, 2, 2, 6);
INSERT INTO `exam` VALUES (31, '高三月考语文', '2018-04-08', NULL, 2, 3, 1);
INSERT INTO `exam` VALUES (32, '高三月考数学', '2018-04-08', NULL, 2, 3, 2);
INSERT INTO `exam` VALUES (33, '高三月考外语', '2018-04-08', NULL, 2, 3, 3);
INSERT INTO `exam` VALUES (34, '高三月考物理', '2018-04-08', NULL, 2, 3, 4);
INSERT INTO `exam` VALUES (35, '高三月考化学', '2018-04-08', NULL, 2, 3, 5);
INSERT INTO `exam` VALUES (36, '高三月考生物', '2018-04-08', NULL, 2, 3, 6);

-- ----------------------------
-- Table structure for examtype
-- ----------------------------
DROP TABLE IF EXISTS `examtype`;
CREATE TABLE `examtype`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of examtype
-- ----------------------------
INSERT INTO `examtype` VALUES (1, '2018年3月月考');
INSERT INTO `examtype` VALUES (2, '2018年4月月考');

-- ----------------------------
-- Table structure for grade
-- ----------------------------
DROP TABLE IF EXISTS `grade`;
CREATE TABLE `grade`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of grade
-- ----------------------------
INSERT INTO `grade` VALUES (1, '高一');
INSERT INTO `grade` VALUES (2, '高二');
INSERT INTO `grade` VALUES (3, '高三');

-- ----------------------------
-- Table structure for grade_course
-- ----------------------------
DROP TABLE IF EXISTS `grade_course`;
CREATE TABLE `grade_course`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gradeid` int(11) NULL DEFAULT NULL,
  `courseid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `gid_gc_FK`(`gradeid`) USING BTREE,
  INDEX `cid_gc_FK`(`courseid`) USING BTREE,
  CONSTRAINT `courseid_gc_FK` FOREIGN KEY (`courseid`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gradeid_gc_FK` FOREIGN KEY (`gradeid`) REFERENCES `grade` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of grade_course
-- ----------------------------
INSERT INTO `grade_course` VALUES (1, 1, 1);
INSERT INTO `grade_course` VALUES (2, 1, 2);
INSERT INTO `grade_course` VALUES (3, 1, 3);
INSERT INTO `grade_course` VALUES (4, 1, 4);
INSERT INTO `grade_course` VALUES (5, 1, 5);
INSERT INTO `grade_course` VALUES (6, 1, 6);
INSERT INTO `grade_course` VALUES (7, 2, 1);
INSERT INTO `grade_course` VALUES (8, 2, 2);
INSERT INTO `grade_course` VALUES (9, 2, 3);
INSERT INTO `grade_course` VALUES (10, 2, 4);
INSERT INTO `grade_course` VALUES (11, 2, 5);
INSERT INTO `grade_course` VALUES (12, 2, 6);
INSERT INTO `grade_course` VALUES (13, 3, 1);
INSERT INTO `grade_course` VALUES (14, 3, 2);
INSERT INTO `grade_course` VALUES (15, 3, 3);
INSERT INTO `grade_course` VALUES (16, 3, 4);
INSERT INTO `grade_course` VALUES (17, 3, 5);
INSERT INTO `grade_course` VALUES (18, 3, 6);

-- ----------------------------
-- Table structure for manu
-- ----------------------------
DROP TABLE IF EXISTS `manu`;
CREATE TABLE `manu`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parentId` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `url` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of manu
-- ----------------------------
INSERT INTO `manu` VALUES (1, 0, '考试信息', NULL);
INSERT INTO `manu` VALUES (2, 0, '学生信息管理', NULL);
INSERT INTO `manu` VALUES (3, 0, '教师信息管理', NULL);
INSERT INTO `manu` VALUES (4, 0, '基础信息管理', NULL);
INSERT INTO `manu` VALUES (5, 0, '系统管理', NULL);
INSERT INTO `manu` VALUES (6, 0, '教学管理', NULL);
INSERT INTO `manu` VALUES (7, 0, '教师信息', NULL);
INSERT INTO `manu` VALUES (8, 0, '教师系统管理', NULL);
INSERT INTO `manu` VALUES (9, 0, '学生考试及成绩管理', NULL);
INSERT INTO `manu` VALUES (10, 0, '班级信息', NULL);
INSERT INTO `manu` VALUES (11, 0, '学生系统管理', NULL);
INSERT INTO `manu` VALUES (12, 1, '考试安排', NULL);
INSERT INTO `manu` VALUES (13, 1, '成绩列表', NULL);
INSERT INTO `manu` VALUES (14, 2, '学生信息列表', NULL);
INSERT INTO `manu` VALUES (15, 3, '教师列表', NULL);
INSERT INTO `manu` VALUES (16, 4, '年级列表', NULL);
INSERT INTO `manu` VALUES (17, 4, '班级列表', NULL);
INSERT INTO `manu` VALUES (18, 5, '修改权限', NULL);
INSERT INTO `manu` VALUES (19, 5, '个人信息', NULL);
INSERT INTO `manu` VALUES (20, 6, '成绩登记', 'system/addSchoolReport.jsp');
INSERT INTO `manu` VALUES (21, 7, '教师通讯录', NULL);
INSERT INTO `manu` VALUES (22, 8, '个人信息', 'user_teacher_info.jsp');
INSERT INTO `manu` VALUES (23, 9, '成绩查询', 'system/schoolReport.jsp');
INSERT INTO `manu` VALUES (24, 9, '考试安排', NULL);
INSERT INTO `manu` VALUES (25, 10, '学生通讯录', NULL);
INSERT INTO `manu` VALUES (26, 7, '学生通讯录', NULL);
INSERT INTO `manu` VALUES (27, 7, '信息发布', NULL);
INSERT INTO `manu` VALUES (28, 11, '个人信息', 'system/user_student_info.jsp');
INSERT INTO `manu` VALUES (29, 30, '学生登记', 'system/add_student_info.jsp');
INSERT INTO `manu` VALUES (30, 0, '班级管理', NULL);
INSERT INTO `manu` VALUES (31, 30, '班级成绩管理', 'system/leaderTeacher_score_management.jsp');

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of role
-- ----------------------------
INSERT INTO `role` VALUES (1, '管理员');
INSERT INTO `role` VALUES (2, '教师');
INSERT INTO `role` VALUES (3, '学生');
INSERT INTO `role` VALUES (4, '班主任');

-- ----------------------------
-- Table structure for role_manu
-- ----------------------------
DROP TABLE IF EXISTS `role_manu`;
CREATE TABLE `role_manu`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `manu_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of role_manu
-- ----------------------------
INSERT INTO `role_manu` VALUES (1, 1, 1);
INSERT INTO `role_manu` VALUES (2, 1, 2);
INSERT INTO `role_manu` VALUES (3, 1, 3);
INSERT INTO `role_manu` VALUES (4, 1, 4);
INSERT INTO `role_manu` VALUES (5, 1, 5);
INSERT INTO `role_manu` VALUES (6, 2, 6);
INSERT INTO `role_manu` VALUES (7, 2, 7);
INSERT INTO `role_manu` VALUES (8, 2, 8);
INSERT INTO `role_manu` VALUES (9, 3, 9);
INSERT INTO `role_manu` VALUES (10, 3, 10);
INSERT INTO `role_manu` VALUES (11, 3, 11);
INSERT INTO `role_manu` VALUES (12, 4, 6);
INSERT INTO `role_manu` VALUES (13, 4, 7);
INSERT INTO `role_manu` VALUES (14, 4, 8);
INSERT INTO `role_manu` VALUES (15, 4, 30);

-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(12) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `clazzid` int(11) NULL DEFAULT NULL,
  `gradeid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `cid_stu_FK`(`clazzid`) USING BTREE,
  INDEX `grade_student_FK`(`gradeid`) USING BTREE,
  CONSTRAINT `clazzid_student_FK` FOREIGN KEY (`clazzid`) REFERENCES `clazz` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `grade_student_FK` FOREIGN KEY (`gradeid`) REFERENCES `grade` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO `student` VALUES (1, '张三', 1, 1);
INSERT INTO `student` VALUES (3, '王五', 4, 2);
INSERT INTO `student` VALUES (4, '李四', 7, 3);
INSERT INTO `student` VALUES (5, '陈六', 5, 2);
INSERT INTO `student` VALUES (6, '胡七', 1, 1);
INSERT INTO `student` VALUES (8, '胡巴', 2, 1);
INSERT INTO `student` VALUES (9, '周洁', 5, 2);
INSERT INTO `student` VALUES (10, '崔少安', 5, 2);
INSERT INTO `student` VALUES (11, '周少华', 5, 2);
INSERT INTO `student` VALUES (12, '全达', 5, 2);
INSERT INTO `student` VALUES (13, '阿来', 5, 2);
INSERT INTO `student` VALUES (14, '赵又廷', 5, 2);
INSERT INTO `student` VALUES (15, '王三', 5, 2);
INSERT INTO `student` VALUES (16, '程远', 1, 1);
INSERT INTO `student` VALUES (17, '哈尼', 1, 1);
INSERT INTO `student` VALUES (18, '阿布', 2, 1);
INSERT INTO `student` VALUES (19, '查倩孙', 2, 1);
INSERT INTO `student` VALUES (20, '李不适', 3, 1);
INSERT INTO `student` VALUES (21, '周世玲', 3, 1);
INSERT INTO `student` VALUES (22, '柴琳', 3, 1);
INSERT INTO `student` VALUES (23, '吴三', 3, 1);
INSERT INTO `student` VALUES (24, '赵华时', 4, 2);
INSERT INTO `student` VALUES (25, '珍一', 4, 2);
INSERT INTO `student` VALUES (26, '珍一', 4, 2);
INSERT INTO `student` VALUES (27, '陈久', 6, 2);
INSERT INTO `student` VALUES (28, '黄夹克', 6, 2);
INSERT INTO `student` VALUES (29, '黄如意', 6, 2);
INSERT INTO `student` VALUES (30, '郑权', 7, 3);
INSERT INTO `student` VALUES (31, '周石原', 7, 3);
INSERT INTO `student` VALUES (32, '赵克建', 8, 3);
INSERT INTO `student` VALUES (33, '李师师', 8, 3);
INSERT INTO `student` VALUES (34, '关羽', 8, 3);
INSERT INTO `student` VALUES (35, '张菲', 9, 3);
INSERT INTO `student` VALUES (36, '张来鸥', 9, 3);
INSERT INTO `student` VALUES (37, '刘元', 9, 3);

-- ----------------------------
-- Table structure for system
-- ----------------------------
DROP TABLE IF EXISTS `system`;
CREATE TABLE `system`  (
  `id` int(11) NOT NULL,
  `schoolName` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `forbidTeacher` tinyint(2) NULL DEFAULT NULL,
  `forbidStudent` tinyint(2) NULL DEFAULT NULL,
  `noticeTeacher` varchar(500) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `noticeStudent` varchar(500) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Table structure for teacher
-- ----------------------------
DROP TABLE IF EXISTS `teacher`;
CREATE TABLE `teacher`  (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `teacherNum` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES (1, 101);
INSERT INTO `teacher` VALUES (2, 102);
INSERT INTO `teacher` VALUES (3, 103);
INSERT INTO `teacher` VALUES (4, 201);
INSERT INTO `teacher` VALUES (5, 202);
INSERT INTO `teacher` VALUES (6, 203);
INSERT INTO `teacher` VALUES (7, 301);
INSERT INTO `teacher` VALUES (8, 302);
INSERT INTO `teacher` VALUES (9, 303);
INSERT INTO `teacher` VALUES (10, 401);
INSERT INTO `teacher` VALUES (11, 402);
INSERT INTO `teacher` VALUES (12, 403);
INSERT INTO `teacher` VALUES (13, 501);
INSERT INTO `teacher` VALUES (14, 502);
INSERT INTO `teacher` VALUES (15, 503);
INSERT INTO `teacher` VALUES (16, 601);
INSERT INTO `teacher` VALUES (17, 602);
INSERT INTO `teacher` VALUES (18, 603);

-- ----------------------------
-- Table structure for teacher_class
-- ----------------------------
DROP TABLE IF EXISTS `teacher_class`;
CREATE TABLE `teacher_class`  (
  `teacherId` int(11) NOT NULL,
  `classId` int(11) NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of teacher_class
-- ----------------------------
INSERT INTO `teacher_class` VALUES (1, 1);
INSERT INTO `teacher_class` VALUES (1, 2);
INSERT INTO `teacher_class` VALUES (1, 3);
INSERT INTO `teacher_class` VALUES (2, 4);
INSERT INTO `teacher_class` VALUES (2, 5);
INSERT INTO `teacher_class` VALUES (2, 6);
INSERT INTO `teacher_class` VALUES (3, 7);
INSERT INTO `teacher_class` VALUES (3, 8);
INSERT INTO `teacher_class` VALUES (3, 9);
INSERT INTO `teacher_class` VALUES (4, 1);
INSERT INTO `teacher_class` VALUES (4, 2);
INSERT INTO `teacher_class` VALUES (4, 3);
INSERT INTO `teacher_class` VALUES (5, 4);
INSERT INTO `teacher_class` VALUES (5, 5);
INSERT INTO `teacher_class` VALUES (5, 6);
INSERT INTO `teacher_class` VALUES (6, 7);
INSERT INTO `teacher_class` VALUES (6, 8);
INSERT INTO `teacher_class` VALUES (6, 9);
INSERT INTO `teacher_class` VALUES (7, 1);
INSERT INTO `teacher_class` VALUES (7, 2);
INSERT INTO `teacher_class` VALUES (7, 3);
INSERT INTO `teacher_class` VALUES (8, 4);
INSERT INTO `teacher_class` VALUES (8, 5);
INSERT INTO `teacher_class` VALUES (8, 6);
INSERT INTO `teacher_class` VALUES (9, 7);
INSERT INTO `teacher_class` VALUES (9, 8);
INSERT INTO `teacher_class` VALUES (9, 9);
INSERT INTO `teacher_class` VALUES (10, 1);
INSERT INTO `teacher_class` VALUES (10, 2);
INSERT INTO `teacher_class` VALUES (10, 3);
INSERT INTO `teacher_class` VALUES (11, 4);
INSERT INTO `teacher_class` VALUES (11, 5);
INSERT INTO `teacher_class` VALUES (11, 6);
INSERT INTO `teacher_class` VALUES (12, 7);
INSERT INTO `teacher_class` VALUES (12, 8);
INSERT INTO `teacher_class` VALUES (12, 9);
INSERT INTO `teacher_class` VALUES (13, 1);
INSERT INTO `teacher_class` VALUES (13, 2);
INSERT INTO `teacher_class` VALUES (13, 3);
INSERT INTO `teacher_class` VALUES (14, 4);
INSERT INTO `teacher_class` VALUES (14, 5);
INSERT INTO `teacher_class` VALUES (14, 6);
INSERT INTO `teacher_class` VALUES (15, 7);
INSERT INTO `teacher_class` VALUES (15, 8);
INSERT INTO `teacher_class` VALUES (15, 9);
INSERT INTO `teacher_class` VALUES (16, 1);
INSERT INTO `teacher_class` VALUES (16, 2);
INSERT INTO `teacher_class` VALUES (16, 3);
INSERT INTO `teacher_class` VALUES (17, 4);
INSERT INTO `teacher_class` VALUES (17, 5);
INSERT INTO `teacher_class` VALUES (17, 6);
INSERT INTO `teacher_class` VALUES (18, 7);
INSERT INTO `teacher_class` VALUES (18, 8);
INSERT INTO `teacher_class` VALUES (18, 9);

-- ----------------------------
-- Table structure for teacher_course
-- ----------------------------
DROP TABLE IF EXISTS `teacher_course`;
CREATE TABLE `teacher_course`  (
  `teacherId` int(11) NOT NULL,
  `courseId` int(11) NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of teacher_course
-- ----------------------------
INSERT INTO `teacher_course` VALUES (1, 1);
INSERT INTO `teacher_course` VALUES (2, 1);
INSERT INTO `teacher_course` VALUES (3, 1);
INSERT INTO `teacher_course` VALUES (4, 2);
INSERT INTO `teacher_course` VALUES (5, 2);
INSERT INTO `teacher_course` VALUES (6, 2);
INSERT INTO `teacher_course` VALUES (7, 3);
INSERT INTO `teacher_course` VALUES (8, 3);
INSERT INTO `teacher_course` VALUES (9, 3);
INSERT INTO `teacher_course` VALUES (10, 4);
INSERT INTO `teacher_course` VALUES (11, 4);
INSERT INTO `teacher_course` VALUES (12, 4);
INSERT INTO `teacher_course` VALUES (13, 5);
INSERT INTO `teacher_course` VALUES (14, 5);
INSERT INTO `teacher_course` VALUES (15, 5);
INSERT INTO `teacher_course` VALUES (16, 6);
INSERT INTO `teacher_course` VALUES (17, 6);
INSERT INTO `teacher_course` VALUES (18, 6);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `password` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT '111111',
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `sex` varchar(5) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `qq` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL,
  `teacherId` int(11) NULL DEFAULT NULL,
  `studentId` int(11) NULL DEFAULT NULL,
  `adminId` int(11) NULL DEFAULT NULL,
  `roleId` tinyint(1) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `account_user_FK`(`account`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 141 CHARACTER SET = utf8 COLLATE = utf8_unicode_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (87, '虚约束', '111111', '游志强', '男', '156489897', '980043299', NULL, NULL, 1, 1);
INSERT INTO `user` VALUES (88, '高一1班', '111111', '李欣', '女', '1521396645', '864125223', 1, NULL, NULL, 4);
INSERT INTO `user` VALUES (89, '张三', '111111', '张三', '男', '16548484', '894566', NULL, 1, NULL, 3);
INSERT INTO `user` VALUES (90, '李四', '111111', '李四', '女', '1586748749', '8468448', NULL, 4, NULL, 3);
INSERT INTO `user` VALUES (91, '王五', '111111', '王五', '男', '165484848', '459854@qq.com', NULL, 3, NULL, 3);
INSERT INTO `user` VALUES (92, '高一3班', '111111', '张强', '男', '16546854', '465645@qq.com', 4, NULL, NULL, 4);
INSERT INTO `user` VALUES (93, '陈六', '111111', '陈六', '男', '14749899859', '48485@qq.com', NULL, 5, NULL, 3);
INSERT INTO `user` VALUES (94, '胡七', '111111', '胡七', '男', '1564984897498', '854545@qq.com', NULL, 6, NULL, 3);
INSERT INTO `user` VALUES (95, '胡巴', '111111', '胡巴', '女', '18712546658', '6544555@qq.com', NULL, 8, NULL, 3);
INSERT INTO `user` VALUES (96, '高二2班', '111111', '王时', '男', '165486484', '1658544', 11, NULL, NULL, 4);
INSERT INTO `user` VALUES (97, '周洁', '111111', '周洁', '女', '1651654165', NULL, NULL, 9, NULL, 3);
INSERT INTO `user` VALUES (98, '崔少安', '111111', '崔少安', '男', '15465896586', NULL, NULL, 10, NULL, 3);
INSERT INTO `user` VALUES (99, '周少华', '111111', '周少华', '男', '1651', '16516541@qq.com', NULL, 11, NULL, 3);
INSERT INTO `user` VALUES (100, '全达', '111111', '全达', '女', '15846848484', '1864798489', NULL, 12, NULL, 3);
INSERT INTO `user` VALUES (101, '好又来', '111111', '阿来', '男', '14684568', '49845968', NULL, 13, NULL, 3);
INSERT INTO `user` VALUES (102, '赵又廷', '111111', '赵又廷', '男', '18956456898', '64546546', NULL, 14, NULL, 3);
INSERT INTO `user` VALUES (103, '阿三', '111111', '王三', '男', '13645879565', '17453678', NULL, 15, NULL, 3);
INSERT INTO `user` VALUES (104, '高一2班', '111111', '陈菊', '女', NULL, NULL, 7, NULL, NULL, 4);
INSERT INTO `user` VALUES (105, '高二1班', '111111', '黄亮', '男', NULL, NULL, 5, NULL, NULL, 4);
INSERT INTO `user` VALUES (106, '高二3班', '111111', '王案', '女', NULL, NULL, 8, NULL, NULL, 4);
INSERT INTO `user` VALUES (107, '高三1班', '111111', '卿策', '男', NULL, NULL, 9, NULL, NULL, 4);
INSERT INTO `user` VALUES (108, '高三2班', '111111', '成册', '男', NULL, NULL, 6, NULL, NULL, 4);
INSERT INTO `user` VALUES (109, '高三3班', '111111', '吴浩', '男', NULL, NULL, 12, NULL, NULL, 4);
INSERT INTO `user` VALUES (110, '程远', '111111', '程远', '男', '', '', NULL, 16, NULL, 3);
INSERT INTO `user` VALUES (111, '哈尼', '111111', '哈尼', '女', '', '', NULL, 17, NULL, 3);
INSERT INTO `user` VALUES (112, '阿布', '111111', '阿布', '男', '', '', NULL, 18, NULL, 3);
INSERT INTO `user` VALUES (113, '查倩孙', '111111', '查倩孙', NULL, '', '', NULL, 19, NULL, 3);
INSERT INTO `user` VALUES (114, '李不适', '111111', '李不适', NULL, '', '', NULL, 20, NULL, 3);
INSERT INTO `user` VALUES (115, '周世玲', '111111', '周世玲', NULL, '', '', NULL, 21, NULL, 3);
INSERT INTO `user` VALUES (116, '柴琳', '111111', '柴琳', NULL, '', '', NULL, 22, NULL, 3);
INSERT INTO `user` VALUES (117, '吴三', '111111', '吴三', NULL, '', '', NULL, 23, NULL, 3);
INSERT INTO `user` VALUES (118, '赵华时', '111111', '赵华时', NULL, '', '', NULL, 24, NULL, 3);
INSERT INTO `user` VALUES (119, '珍一', '111111', '珍一', NULL, '', '', NULL, 25, NULL, 3);
INSERT INTO `user` VALUES (120, '冯程程', '111111', '冯程程', NULL, '', '', NULL, 26, NULL, 3);
INSERT INTO `user` VALUES (121, '陈久', '111111', '陈久', '男', '', '', NULL, 27, NULL, 3);
INSERT INTO `user` VALUES (122, '黄夹克', '111111', '黄夹克', NULL, '', '', NULL, 28, NULL, 3);
INSERT INTO `user` VALUES (123, '黄如意', '111111', '黄如意', NULL, '', '', NULL, 29, NULL, 3);
INSERT INTO `user` VALUES (124, '郑权', '111111', '郑权', NULL, '', '', NULL, 30, NULL, 3);
INSERT INTO `user` VALUES (125, '周石原', '111111', '周石原', NULL, '', '', NULL, 31, NULL, 3);
INSERT INTO `user` VALUES (126, '赵克建', '111111', '赵克建', NULL, '', '', NULL, 32, NULL, 3);
INSERT INTO `user` VALUES (127, '李师师', '111111', '李师师', NULL, '', '', NULL, 33, NULL, 3);
INSERT INTO `user` VALUES (128, '关羽', '111111', '关羽', NULL, '', '', NULL, 34, NULL, 3);
INSERT INTO `user` VALUES (129, '张菲', '111111', '张菲', NULL, '', '', NULL, 35, NULL, 3);
INSERT INTO `user` VALUES (130, '张来鸥', '111111', '张来鸥', NULL, '', '', NULL, 36, NULL, 3);
INSERT INTO `user` VALUES (131, '刘元', '111111', '刘元', NULL, '', '', NULL, 37, NULL, 3);
INSERT INTO `user` VALUES (132, '高二语文', '111111', '杨树成', NULL, NULL, NULL, 2, NULL, NULL, 2);
INSERT INTO `user` VALUES (133, '高三语文', '111111', '陈世龙', NULL, NULL, NULL, 3, NULL, NULL, 2);
INSERT INTO `user` VALUES (134, '高一物理', '111111', '任浩', NULL, NULL, NULL, 10, NULL, NULL, 2);
INSERT INTO `user` VALUES (135, '高一化学', '111111', '房事龙', NULL, NULL, NULL, 13, NULL, NULL, 2);
INSERT INTO `user` VALUES (136, '高二化学', '111111', '常赛', NULL, NULL, NULL, 14, NULL, NULL, 2);
INSERT INTO `user` VALUES (137, '高三化学', '111111', '陈竹', NULL, NULL, NULL, 15, NULL, NULL, 2);
INSERT INTO `user` VALUES (138, '高一生物', '111111', '水岸', NULL, NULL, NULL, 16, NULL, NULL, 2);
INSERT INTO `user` VALUES (139, '高二生物', '111111', '阳德玛', NULL, NULL, NULL, 17, NULL, NULL, 2);
INSERT INTO `user` VALUES (140, '高三生物', '111111', '胡杨林', NULL, NULL, NULL, 18, NULL, NULL, 2);

SET FOREIGN_KEY_CHECKS = 1;
