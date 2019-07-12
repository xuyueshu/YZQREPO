package cn.tedu.store.controller;

import java.io.File;
import java.io.IOException;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
@Controller
public class CommonsController {
	
	/**
	 * 上传文件
	 * @param file
	 * @return
	 * @throws IllegalStateException
	 * @throws IOException
	 */
	@RequestMapping("/upload.do")
	public String handleUpload(@RequestParam CommonsMultipartFile[] file,HttpServletRequest request) throws IllegalStateException, IOException {
		//目标文件
		//获取当前的实际路径
		String uploadDirPath=request.getServletContext().getRealPath("upload");
		for (CommonsMultipartFile commonsMultipartFile : file) {//一次上传多个文件
			String fileName=commonsMultipartFile.getOriginalFilename();
			File dest=new File(uploadDirPath,fileName);
			if(!dest.getParentFile().exists()) {
				dest.getParentFile().mkdirs();
				commonsMultipartFile.transferTo(dest);
				
			}
		}
		return null;
		
		//检查上传文件夹是否存在
	
		//将用户上传的文件数据（尚且再内存中）保存为文件
		
		
		
	}
}
