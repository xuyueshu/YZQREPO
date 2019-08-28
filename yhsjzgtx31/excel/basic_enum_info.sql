/*
 Navicat Premium Data Transfer

 Source Server         : 华为云教学整改标准化
 Source Server Type    : MySQL
 Source Server Version : 50642
 Source Host           : 119.3.74.110:3306
 Source Schema         : diagnosis3

 Target Server Type    : MySQL
 Target Server Version : 50642
 File Encoding         : 65001

 Date: 23/04/2019 10:25:06
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for basic_enum_info
-- ----------------------------
DROP TABLE IF EXISTS `basic_enum_info`;
CREATE TABLE `basic_enum_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(100) NOT NULL COMMENT '枚举代码',
  `name` varchar(100) NOT NULL COMMENT '枚举名称',
  `parent_code` varchar(100) NOT NULL COMMENT '父级枚举代码',
  `parent_name` varchar(100) NOT NULL COMMENT '父级枚举名称',
  `status` smallint(6) NOT NULL COMMENT '状态:1可用,0不可用',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8mb4 COMMENT='枚举基础信息表';

-- ----------------------------
-- Records of basic_enum_info
-- ----------------------------
BEGIN;
INSERT INTO `basic_enum_info` VALUES (1, '1', '综合一等奖', 'XYJXJ', '学院奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (2, '2', '综合二等奖', 'XYJXJ', '学院奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (3, '3', '综合三等奖', 'XYJXJ', '学院奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (4, '1', '国家奖学金', 'GJJXJ', '国家奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (5, '1', '特殊贡献奖', 'QYJXJ', '特殊及其他奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (6, '1', '一般困难', 'PKDJ', '贫困生级别', 1);
INSERT INTO `basic_enum_info` VALUES (7, '2', '特困', 'PKDJ', '贫困生级别', 1);
INSERT INTO `basic_enum_info` VALUES (8, '3', '疑似经济困难', 'PKDJ', '贫困生级别', 1);
INSERT INTO `basic_enum_info` VALUES (9, 'ZTYLJN', '技能比赛获奖', 'HY', '学生获奖情况', 1);
INSERT INTO `basic_enum_info` VALUES (10, 'CXCY', '创新创业获奖', 'HY', '学生获奖情况', 1);
INSERT INTO `basic_enum_info` VALUES (11, 'KJWH', '科技文化作品', 'HY', '学生获奖情况', 1);
INSERT INTO `basic_enum_info` VALUES (12, 'JCXK', '基础性学科获奖', 'HY', '学生获奖情况', 1);
INSERT INTO `basic_enum_info` VALUES (13, 'WHTY', '文体比赛获奖', 'HY', '学生获奖情况', 1);
INSERT INTO `basic_enum_info` VALUES (14, 'OTHER', '其他获奖', 'HY', '学生获奖情况', 1);
INSERT INTO `basic_enum_info` VALUES (15, 'GJSFZY', '国家示范专业', 'ZYJSLX', '专业建设类型', 1);
INSERT INTO `basic_enum_info` VALUES (16, 'GGZY', '骨干专业', 'ZYJSLX', '专业建设类型', 1);
INSERT INTO `basic_enum_info` VALUES (17, 'YLZY', '一流专业', 'ZYJSLX', '专业建设类型', 1);
INSERT INTO `basic_enum_info` VALUES (18, 'ZDZY', '重点专业', 'ZYJSLX', '专业建设类型', 1);
INSERT INTO `basic_enum_info` VALUES (19, 'GGSDZY', '专业综合改革试点专业专业', 'ZYJSLX', '专业建设类型', 1);
INSERT INTO `basic_enum_info` VALUES (20, 'CJ', '初级证书', 'ZSTS', '证书条数', 1);
INSERT INTO `basic_enum_info` VALUES (21, 'ZJ', '中级证书', 'ZSTS', '证书条数', 1);
INSERT INTO `basic_enum_info` VALUES (22, 'GJ', '高级证书', 'ZSTS', '证书条数', 1);
INSERT INTO `basic_enum_info` VALUES (23, 'WD', '无等级证书', 'ZSTS', '证书条数', 1);
INSERT INTO `basic_enum_info` VALUES (26, 'XYJZD', '学院级重点专业', 'ZYJSLX', '专业技术类型', 1);
INSERT INTO `basic_enum_info` VALUES (27, '2', '省级奖学金', 'GJJXJ', '国家奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (28, '3', '市级奖学金', 'GJJXJ', '国家奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (29, '2', '其他奖学金', 'QYJXJ', '特殊及其他奖学金', 1);
INSERT INTO `basic_enum_info` VALUES (30, 'YBGH', '教育部规划教材', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (31, 'JYBJP', '教育部精品教材', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (32, 'HYJP', '行业部委精品教材', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (33, 'GJYLZY', '国家一流专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (34, 'SJYLZY', '省级一流专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (35, 'GGZY', '骨干专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (36, 'TSZY', '特色专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (37, 'ZYSJK', '专业实践课', 'COURSEATTR', '专业课程类型', 1);
INSERT INTO `basic_enum_info` VALUES (38, 'ZYLLK', '专业理论课', 'COURSEATTR', '专业课程类型', 1);
INSERT INTO `basic_enum_info` VALUES (39, 'GGJCK', '公共基础课', 'COURSEATTR', '专业课程类型', 1);
INSERT INTO `basic_enum_info` VALUES (40, 'QT', '其他', 'COURSEATTR', '专业课程类型', 1);
INSERT INTO `basic_enum_info` VALUES (41, 'GJJTS', '国家级特色专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (42, 'SJTS', '省级特色专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (43, 'XYJTS', '学院级特色专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (44, 'GJJZD', '国家级重点专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (45, 'SJZD', '省级重点专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (46, 'XYJZD', '学院级重点专业', 'ZYJSMB', '专业建设目标', 1);
INSERT INTO `basic_enum_info` VALUES (47, 'RX', '任选', 'COURSETYPE', '课程必修类型', 1);
INSERT INTO `basic_enum_info` VALUES (48, 'BX', '必修', 'COURSETYPE', '课程必修类型', 1);
INSERT INTO `basic_enum_info` VALUES (49, 'XW', '学位', 'COURSETYPE', '课程必修类型', 1);
INSERT INTO `basic_enum_info` VALUES (50, 'XX', '限选', 'COURSETYPE', '课程必修类型', 1);
INSERT INTO `basic_enum_info` VALUES (51, 'LGNY', '理工农医类', 'ZYDL', '专业所属大类', 1);
INSERT INTO `basic_enum_info` VALUES (52, 'RWSK', '人文社科类', 'ZYDL', '专业所属大类', 1);
INSERT INTO `basic_enum_info` VALUES (53, 'QT', '其他类', 'ZYDL', '专业所属大类', 1);
INSERT INTO `basic_enum_info` VALUES (54, 'YDJ', '一等奖', 'ZYXYDJ', '专业校外奖金等级', 1);
INSERT INTO `basic_enum_info` VALUES (55, 'EDJ', '二等奖', 'ZYXYDJ', '专业校外奖金等级', 1);
INSERT INTO `basic_enum_info` VALUES (56, 'SDJ', '三等奖', 'ZYXYDJ', '专业校外奖金等级', 1);
INSERT INTO `basic_enum_info` VALUES (57, 'GJ', '国家', 'ZYXYJB', '专业校外级别', 1);
INSERT INTO `basic_enum_info` VALUES (58, 'SJ', '省', 'ZYXYJB', '专业校外级别', 1);
INSERT INTO `basic_enum_info` VALUES (59, 'CJ', '市', 'ZYXYJB', '专业校外级别', 1);
INSERT INTO `basic_enum_info` VALUES (60, 'ALVL', 'A类', 'ZYXYFL', '专业校外分类', 1);
INSERT INTO `basic_enum_info` VALUES (61, 'BLVL', 'B类', 'ZYXYFL', '专业校外分类', 1);
INSERT INTO `basic_enum_info` VALUES (62, 'CLVL', 'C类', 'ZYXYFL', '专业校外分类', 1);
INSERT INTO `basic_enum_info` VALUES (63, 'CQ', '出勤', 'XXTD', '学期态度类别', 1);
INSERT INTO `basic_enum_info` VALUES (64, 'KK', '旷课', 'XXTD', '学习态度类别', 1);
INSERT INTO `basic_enum_info` VALUES (65, 'QJ', '请假', 'XXTD', '学习态度类别', 1);
INSERT INTO `basic_enum_info` VALUES (66, 'CD', '迟到', 'XXTD', '学习态度类别', 1);
INSERT INTO `basic_enum_info` VALUES (67, 'ZD', '早退', 'XXTD', '学习态度类别', 1);
INSERT INTO `basic_enum_info` VALUES (68, 'SDJS', '三大检索论文', 'LW', '论文', 1);
INSERT INTO `basic_enum_info` VALUES (69, 'HXQK', '核心期刊论文', 'LW', '论文', 1);
INSERT INTO `basic_enum_info` VALUES (70, 'SJ', '省级论文', 'LW', '论文', 1);
INSERT INTO `basic_enum_info` VALUES (71, 'OTHER', '其他', 'LW', '论文', 1);
INSERT INTO `basic_enum_info` VALUES (72, 'GJJ', '国家级', 'HJCG', '获奖成果', 1);
INSERT INTO `basic_enum_info` VALUES (73, 'SBJ', '省部级', 'HJCG', '获奖成果', 1);
INSERT INTO `basic_enum_info` VALUES (74, 'SJ', '市级', 'HJCG', '获奖成果', 1);
INSERT INTO `basic_enum_info` VALUES (75, 'OTHER', '其他', 'HJCG', '获奖成果', 1);
INSERT INTO `basic_enum_info` VALUES (76, 'FMZL', '发明专利', 'ZL', '专利', 1);
INSERT INTO `basic_enum_info` VALUES (77, 'WGSJ', '外观设计', 'ZL', '专利', 1);
INSERT INTO `basic_enum_info` VALUES (78, 'SYXX', '实用新型', 'ZL', '专利', 1);
INSERT INTO `basic_enum_info` VALUES (79, 'RJZZ', '软件著作', 'ZL', '专利', 1);
INSERT INTO `basic_enum_info` VALUES (80, 'OTHER', '其他', 'ZL', '专利', 1);
INSERT INTO `basic_enum_info` VALUES (81, 'HXKT', '横向课题', 'KT', '课题', 1);
INSERT INTO `basic_enum_info` VALUES (82, 'ZXKT', '纵向课题', 'KT', '课题', 1);
INSERT INTO `basic_enum_info` VALUES (83, 'OTHER', '其他', 'KT', '课题', 1);
INSERT INTO `basic_enum_info` VALUES (84, 'SZPX', '师资培训', 'SHPX', '社会培训', 1);
INSERT INTO `basic_enum_info` VALUES (85, 'SHRYPX', '社会人员培训', 'SHPX', '社会培训', 1);
INSERT INTO `basic_enum_info` VALUES (86, 'JNJD', '技能鉴定', 'SHPX', '社会培训', 1);
INSERT INTO `basic_enum_info` VALUES (87, 'GYXPX', '公益性培训', 'SHPX', '社会培训', 1);
INSERT INTO `basic_enum_info` VALUES (88, 'CXCY', '创新创业类', 'FZKC', '发展类课程', 1);
INSERT INTO `basic_enum_info` VALUES (89, 'SZKZ', '素质扩展类', 'FZKC', '发展类课程', 1);
INSERT INTO `basic_enum_info` VALUES (90, 'QT', '其他(非发展类课程)', 'FZKC', '发展类课程', 1);
INSERT INTO `basic_enum_info` VALUES (91, 'DWJY', '单位就业', 'JYQX', '就业去向', 1);
INSERT INTO `basic_enum_info` VALUES (92, 'SX', '升学', 'JYQX', '就业去向', 1);
INSERT INTO `basic_enum_info` VALUES (93, 'WJY', '未就业', 'JYQX', '就业去向', 1);
INSERT INTO `basic_enum_info` VALUES (94, 'CY', '创业', 'JYQX', '就业去向', 1);
INSERT INTO `basic_enum_info` VALUES (95, 'HZ', '合资', 'COMTYPE', '企业性质', 1);
INSERT INTO `basic_enum_info` VALUES (96, 'DZ', '独资', 'COMTYPE', '企业性质', 1);
INSERT INTO `basic_enum_info` VALUES (97, 'GY', '国有', 'COMTYPE', '企业性质', 1);
INSERT INTO `basic_enum_info` VALUES (98, 'SY', '私营', 'COMTYPE', '企业性质', 1);
INSERT INTO `basic_enum_info` VALUES (99, '0', '其他', 'JSKHLX', '教师考核类型', 1);
INSERT INTO `basic_enum_info` VALUES (100, '1', '不合格', 'JSKHLX', '教师考核类型', 1);
INSERT INTO `basic_enum_info` VALUES (101, '2', '合格', 'JSKHLX', '教师考核类型', 1);
INSERT INTO `basic_enum_info` VALUES (102, '3', '优秀', 'JSKHLX', '教师考核类型', 1);
INSERT INTO `basic_enum_info` VALUES (103, '0', '其他', 'JSHJLX', '教师获奖类型', 1);
INSERT INTO `basic_enum_info` VALUES (104, '1', '国家级奖项', 'JSHJLX', '教师获奖类型', 1);
INSERT INTO `basic_enum_info` VALUES (105, '2', '省部级奖项', 'JSHJLX', '教师获奖类型', 1);
INSERT INTO `basic_enum_info` VALUES (106, '3', '市级奖项', 'JSHJLX', '教师获奖类型', 1);
INSERT INTO `basic_enum_info` VALUES (107, 'XQHZ', '校企合作开发教材', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (108, 'ZBJC', '自编教材', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (109, 'JY', '讲义', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (110, 'QT', '其他', 'JCLX', '教材类型', 1);
INSERT INTO `basic_enum_info` VALUES (111, 'GJJ', '国家级', 'KCDJ', '课程等级', 1);
INSERT INTO `basic_enum_info` VALUES (112, 'SBJ', '省部级', 'KCDJ', '课程等级', 1);
INSERT INTO `basic_enum_info` VALUES (113, 'DSJ', '地市级', 'KCDJ', '课程等级', 1);
INSERT INTO `basic_enum_info` VALUES (114, 'YXJ', '院校级', 'KCDJ', '课程等级', 1);
INSERT INTO `basic_enum_info` VALUES (115, 'QT', '其他', 'KCDJ', '课程等级', 1);
INSERT INTO `basic_enum_info` VALUES (116, 'LDBZ', '领导班子', 'GLLX', '管理队伍类型', 1);
INSERT INTO `basic_enum_info` VALUES (117, 'KZGB', '科职干部', 'GLLX', '管理队伍类型', 1);
INSERT INTO `basic_enum_info` VALUES (118, 'CZGB', '处职干部', 'GLLX', '管理队伍类型', 1);
INSERT INTO `basic_enum_info` VALUES (119, 'QT', '其他管理人员', 'GLLX', '管理队伍类型', 1);
INSERT INTO `basic_enum_info` VALUES (120, '35YX', '35岁以下', 'NLJG', '管理队伍年龄结构', 1);
INSERT INTO `basic_enum_info` VALUES (121, '36-45', '36-45岁', 'NLJG', '管理队伍年龄结构', 1);
INSERT INTO `basic_enum_info` VALUES (122, '46-60', '46-60岁', 'NLJG', '管理队伍年龄结构', 1);
INSERT INTO `basic_enum_info` VALUES (124, '61YS', '61岁以上', 'NLJG', '管理队伍年龄结构', 1);
INSERT INTO `basic_enum_info` VALUES (125, 'ZGZC', '正高职称', 'ZCJG', '管理队伍职称结构', 1);
INSERT INTO `basic_enum_info` VALUES (126, 'FGZC', '副高职称', 'ZCJG', '管理队伍职称结构', 1);
INSERT INTO `basic_enum_info` VALUES (127, 'ZJZC', '中级职称', 'ZCJG', '管理队伍职称结构', 1);
INSERT INTO `basic_enum_info` VALUES (128, 'CJZC', '初级职称', 'ZCJG', '管理队伍职称结构', 1);
INSERT INTO `basic_enum_info` VALUES (129, 'BSXL', '博士学历', 'XLJG', '管理队伍学历结构', 1);
INSERT INTO `basic_enum_info` VALUES (130, 'SSXL', '硕士学历', 'XLJG', '管理队伍学历结构', 1);
INSERT INTO `basic_enum_info` VALUES (131, 'BKXL', '本科学历', 'XLJG', '管理队伍学历结构', 1);
INSERT INTO `basic_enum_info` VALUES (132, 'ZKXL', '专科及以下学历', 'XLJG', '管理队伍学历结构', 1);
INSERT INTO `basic_enum_info` VALUES (133, 'QT', '其他', 'COMTYPE', '企业性质', 1);
INSERT INTO `basic_enum_info` VALUES (134, 'GJYDZXJ', '国家一等助学金', 'ZXJDJ', '助学金等级', 1);
INSERT INTO `basic_enum_info` VALUES (135, 'GJEDZXJ', '国家二等助学金', 'ZXJDJ', '助学金等级', 1);
INSERT INTO `basic_enum_info` VALUES (136, 'GJSDZXJ', '国家三等助学金', 'ZXJDJ', '助学金等级', 1);
INSERT INTO `basic_enum_info` VALUES (137, 'SJYDZXJ', '省级一等助学金', 'ZXJDJ', '助学金等级', 1);
INSERT INTO `basic_enum_info` VALUES (138, 'SJEDZXJ', '省级二等助学金', 'ZXJDJ', '助学金等级', 1);
INSERT INTO `basic_enum_info` VALUES (139, 'SJSDZXJ', '省级三等助学金', 'ZXJDJ', '助学金等级', 1);
INSERT INTO `basic_enum_info` VALUES (140, 'JXNLBSHJ', '教学能力比赛获奖', 'JSHJMC', '教师获奖名称', 1);
INSERT INTO `basic_enum_info` VALUES (141, 'ZYJNJSHJ', '专业技能竞赛获奖', 'JSHJMC', '教师获奖名称', 1);
INSERT INTO `basic_enum_info` VALUES (142, 'JXZLGCHJ', '教学质量工程获奖', 'JSHJMC', '教师获奖名称', 1);
INSERT INTO `basic_enum_info` VALUES (143, 'COLLEGE', '学院', 'CM', '系统层面', 1);
INSERT INTO `basic_enum_info` VALUES (144, 'MAJOR', '专业', 'CM', '系统层面', 1);
INSERT INTO `basic_enum_info` VALUES (145, 'TEACHER', '师资', 'CM', '系统层面', 1);
INSERT INTO `basic_enum_info` VALUES (146, 'STUDENT', '学生', 'CM', '系统层面', 1);
INSERT INTO `basic_enum_info` VALUES (147, 'COURSE', '课程', 'CM', '系统层面', 1);
INSERT INTO `basic_enum_info` VALUES (148, 'ALL', '全部', 'CM', '系统层面', 1);
INSERT INTO `basic_enum_info` VALUES (149, 'ZYJS', '专业建设', 'RESOURCETYPE', '教师资源建设分类', 1);
INSERT INTO `basic_enum_info` VALUES (150, 'KCJS', '课程建设', 'RESOURCETYPE', '教师资源建设分类', 1);
INSERT INTO `basic_enum_info` VALUES (151, 'SXJDJS', '实训基地建设', 'RESOURCETYPE', '教师资源建设分类', 1);
INSERT INTO `basic_enum_info` VALUES (152, 'ZDGCJS', '重大工程建设', 'RESOURCETYPE', '教师资源建设分类', 1);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
