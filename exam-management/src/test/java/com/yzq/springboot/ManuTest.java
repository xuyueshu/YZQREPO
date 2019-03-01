package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.Manu;
import com.yzq.springboot.service.IManuService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class ManuTest {
	@Autowired
	private IManuService manuService;
	
	@Test
	public void showManuList() {
		List<Manu> list=manuService.getManuList(88);
		System.out.println(list);
	}

}
