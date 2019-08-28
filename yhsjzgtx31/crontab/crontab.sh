#!/bin/sh
#################################################
#################################################
cd `dirname $0`
source ../config.sh
exec_dir everyday_run

#自行整理表
sh ${SHELL_PATH}/diagnosis/basic/app/basic_area_info.sh
sh ${SHELL_PATH}/diagnosis/basic/app/basic_enum_info.sh
sh ${SHELL_PATH}/diagnosis/basic/app/basic_semester_info.sh


#################################################
### 基础表
### 执行依赖: 无依赖
#################################################
sh ${SHELL_PATH}/diagnosis/basic/basic_class_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_course_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_department_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_ecard_consume_record.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_instructor_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_major_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_network_record.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_student_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_teacher_info.sh
sh ${SHELL_PATH}/diagnosis/basic/basic_textbook_info.sh

sh ${SHELL_PATH}/diagnosis/college/college_admin_team_info.sh
sh ${SHELL_PATH}/diagnosis/college/college_basic_info.sh
sh ${SHELL_PATH}/diagnosis/college/college_digital_campus.sh
sh ${SHELL_PATH}/diagnosis/college/college_exit_record.sh
sh ${SHELL_PATH}/diagnosis/college/college_international_cooperation.sh
sh ${SHELL_PATH}/diagnosis/college/college_social_influence_count.sh

sh ${SHELL_PATH} /diagnosis/course/course_group_course_info.sh
sh ${SHELL_PATH} /diagnosis/course/course_group_info.sh
sh ${SHELL_PATH} /diagnosis/course/course_group_teacher_info.sh
sh ${SHELL_PATH} /diagnosis/course/course_implement.sh
sh ${SHELL_PATH} /diagnosis/course/course_kpi_standard_state.sh
sh ${SHELL_PATH} /diagnosis/course/course_resource.sh
sh ${SHELL_PATH} /diagnosis/course/course_training_info.sh

sh ${SHELL_PATH}/diagnosis/major/major_course_record.sh
sh ${SHELL_PATH}/diagnosis/major/major_donation_major_count.sh
sh ${SHELL_PATH}/diagnosis/major/major_enroll_area_count.sh
sh ${SHELL_PATH}/diagnosis/major/major_enroll_student.sh
sh ${SHELL_PATH}/diagnosis/major/major_excellent_graduate.sh
sh ${SHELL_PATH}/diagnosis/major/major_instructional_resources.sh
sh ${SHELL_PATH}/diagnosis/major/major_outSchool_award.sh
sh ${SHELL_PATH}/diagnosis/major/major_post_practice_count.sh
sh ${SHELL_PATH}/diagnosis/major/major_social_work.sh
sh ${SHELL_PATH}/diagnosis/major/major_trainingProject_detailed.sh
sh ${SHELL_PATH}/diagnosis/major/major_trainingRoom_detailed.sh

sh ${SHELL_PATH}/diagnosis/party/party_activity_info.sh
sh ${SHELL_PATH}/diagnosis/party/party_fee_info.sh
sh ${SHELL_PATH}/diagnosis/party/party_honor_info.sh

sh ${SHELL_PATH}/diagnosis/scientific/scientific_author_patent_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_award_result_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_paper_basic_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_paper_personnel_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_patent_achievements.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_project_basic_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_project_funds_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_project_personnel_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_team_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_work_basic_info.sh
sh ${SHELL_PATH}/diagnosis/scientific/scientific_work_personnel_info.sh

sh ${SHELL_PATH}/diagnosis/student/student_attendance_info.sh
sh ${SHELL_PATH}/diagnosis/student/student_award_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_birthplace_loan_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_community_information.sh
sh ${SHELL_PATH}/diagnosis/student/student_diligent_study_detailed.sh
sh ${SHELL_PATH}/diagnosis/student/student_directed_education.sh
sh ${SHELL_PATH}/diagnosis/student/student_disciplinary_info.sh
sh ${SHELL_PATH}/diagnosis/student/student_dormitory_sanitation.sh
sh ${SHELL_PATH}/diagnosis/student/student_excellent.sh
sh ${SHELL_PATH}/diagnosis/student/student_grade_test_detailed.sh
sh ${SHELL_PATH}/diagnosis/student/student_graduate_employment_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_grant_detailed.sh
sh ${SHELL_PATH}/diagnosis/student/student_job_orientation.sh
sh ${SHELL_PATH}/diagnosis/student/student_join_community.sh
sh ${SHELL_PATH}/diagnosis/student/student_lecture_info.sh
sh ${SHELL_PATH}/diagnosis/student/student_papers.sh
sh ${SHELL_PATH}/diagnosis/student/student_physical_test_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_poor_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_psychological_test_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_pull_tonight.sh
sh ${SHELL_PATH}/diagnosis/student/student_scholarship_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_score_record.sh
sh ${SHELL_PATH}/diagnosis/student/student_social_activity.sh

sh ${SHELL_PATH}/diagnosis/teacher/teacher_awards_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_change_class.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_course_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_growing_assessment_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_growing_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_guidance_competition.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_guidance_help_record.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_project_count.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_resource_build_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_social_work.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_student_book_lending_record.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_teaching_research_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_teaching_research_personnel_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_textbook_personnel_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/teacher_workload_information_record.sh

sh ${SHELL_PATH}/diagnosis/basic/app/basic_semester_student_info.sh

sh ${SHELL_PATH}/diagnosis/college/app/college_assets_student_avg.sh
sh ${SHELL_PATH}/diagnosis/college/app/college_class_hours_info.sh
sh ${SHELL_PATH}/diagnosis/college/app/college_enrolment_method_count.sh
sh ${SHELL_PATH}/diagnosis/college/app/college_party_info.sh
sh ${SHELL_PATH}/diagnosis/college/app/college_scientific_count.sh
sh ${SHELL_PATH}/diagnosis/college/app/college_social_work_count.sh

sh ${SHELL_PATH}/diagnosis/course/app/course_feedback.sh

sh ${SHELL_PATH}/diagnosis/major/app/major_abroad_communication_count.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_chief_editor_textbook.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_development_course.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_donation_all_count.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_examination_rate.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_goods_online_course.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_plan_student.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_scientific_info.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_student_birthplace.sh
sh ${SHELL_PATH}/diagnosis/major/app/major_total_info.sh

sh ${SHELL_PATH}/diagnosis/student/app/student_award_record.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_behavior_count.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_behavior_detailed.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_club_activity.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_grade_examination_count.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_graduate_employment_count.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_income_record.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_netPlay_record.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_one_card.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_playnet_time_avg.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_summary_achievements_count.sh
sh ${SHELL_PATH}/diagnosis/student/app/student_summary_achievements_record.sh

sh ${SHELL_PATH}/diagnosis/teacher/app/teacher_community_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/app/teacher_high_level_count.sh
sh ${SHELL_PATH}/diagnosis/teacher/app/teacher_lessons_info.sh
sh ${SHELL_PATH}/diagnosis/teacher/app/teacher_managerial_position_record.sh

finish