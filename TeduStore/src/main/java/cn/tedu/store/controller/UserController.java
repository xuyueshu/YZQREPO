package cn.tedu.store.controller;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.commons.CommonsMultipartFile;

import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.entity.User;
import cn.tedu.store.service.IUserService;
import cn.tedu.store.service.exception.UploadAvatarException;

@Controller
@RequestMapping("/user")
public class UserController extends BaseController {
	@Autowired
	private IUserService service;
	
	/**
	 *用户注册
	 * @param username
	 * @param password
	 * @param emailimport cn.tedu.store.servce.exception.UploadAvatarException;
	 * @param phone
	 * @param gender
	 * @return
	 */
	@RequestMapping(value="/handle_reg.do",method=RequestMethod.POST)//可以先不添加提交方式的限制，这样方便用get方法在地址栏进行测试
	@ResponseBody
	public ResponseResult<Void> handleReg(@RequestParam("username") String username,@RequestParam("password") String password,
			String email,String phone,@RequestParam(value="gender",required=false,defaultValue="1")Integer gender) {
			
			User user=new User(username,password,email,phone,gender);
			service.reg(user);
		return new ResponseResult<Void>();
		
	}
	/**
	 * 用户登录
	 * @param session
	 * @param username
	 * @param password
	 * @return
	 */
	@RequestMapping(value="/handle_login.do",method=RequestMethod.POST)//可以先不添加提交方式的限制，这样方便用get方法在地址栏进行测试
	@ResponseBody
	public ResponseResult<Void> handleLogin(HttpSession session,@RequestParam("username") String username,@RequestParam("password") String password) {
			
			User user=service.login(username, password);
			session.setAttribute("uid", user.getId());
			session.setAttribute("username", username);
			
		return new ResponseResult<Void>();
		
	}
	/**
	 * 修改密码
	 * @param session
	 * @param oldPassword
	 * @param newPassword
	 * @return
	 */
	@RequestMapping(value="/handle_changePassword.do",method=RequestMethod.POST)
	@ResponseBody
	public ResponseResult<Void> changePassword(HttpSession session,@RequestParam("oldPassword")String oldPassword,
			@RequestParam("newPassword")String newPassword) {
			service.changePasswordByOldPassword(getUidFromSession(session), oldPassword, newPassword);
			return new ResponseResult<Void>();
	}
	/**
	 * 修改个人信息
	 * @param session
	 * @param user
	 * @return
	 */
	@RequestMapping(value="/handle_changeInfo.do")
	@ResponseBody
	public ResponseResult<String> changeUserInfo(HttpServletRequest request,HttpSession session,User user,@RequestParam CommonsMultipartFile avatarFile) {
		System.out.println("uid="+session.getAttribute("uid"));
			if("".equals(user.getUsername())) {
				user.setUsername(null);
			}
      if("".equals(user.getEmail())) {
				user.setEmail(null);
			}
   // 判断此次操作是否上传了头像
   		// avatarFile.isEmpty();
   		// 上传头像，并获取上传后的路径
   		String avatarPath = uploadAvatar(request, avatarFile);
   		// 把头像文件的路径封装，以写入到数据表中
   		user.setAvatar(avatarPath);
   		
   	    // 从session获取uid
   		Integer uid = getUidFromSession(session);
   	    // 将uid封装到参数user中
   		user.setId(uid);
   	    // 执行修改：
   		service.changeInfo(user);
   	    // 返回
   		ResponseResult<String> rr= new ResponseResult<String>();
   		rr.setData(user.getAvatar());
   		return rr;
	}
	
	
	
	/**
	 * 上传头像
	 * @param request HttpServletRequest
	 * @param avatarFile CommonsMultipartFile
	 * @return 成功上传后，文件保存到的路径
	 * @throws UploadAvatarException 上传头像异常
	 */
	private String uploadAvatar(HttpServletRequest request,CommonsMultipartFile avatarFile)throws UploadAvatarException {
		// 确定头像保存到的文件夹的路径：项目根目录下的upload文件夹
		String uploadDirPath= request.getServletContext().getRealPath("upload");
		// 确定头像保存到的文件夹
		File uploadDir = new File(uploadDirPath);
		// 确保文件夹存在
		if (!uploadDir.exists()) {
			uploadDir.mkdirs();
		}
		// 确定头像文件的扩展名，例如：aaa.bbb.ccc.jpg，所需的是.jpg
		int beginIndex = avatarFile.getOriginalFilename().lastIndexOf(".");
		String suffix = avatarFile.getOriginalFilename().substring(beginIndex);
		// 确定头像文件的文件名，必须唯一
		String fileName = UUID.randomUUID().toString() + suffix;
		// 确定头像保存到哪个文件
		File dest = new File(uploadDir, fileName);
				
		// 保存头像文件
		try {
			avatarFile.transferTo(dest);
			return "upload/" + fileName;
		} catch (IllegalStateException e) {
			throw new UploadAvatarException("非法状态！");
		} catch (IOException e) {
			throw new UploadAvatarException("读写出错！");
		}
	
	}
	/**
	 * 在前端页面返回用户信息
	 * @param session
	 * @return
	 */
	@RequestMapping("/getInfo.do")
	@ResponseBody
	public ResponseResult<User> getInfo(HttpSession session){
		Integer id=getUidFromSession(session);
		User user=service.getUserById(id);
		ResponseResult<User> rr=new ResponseResult<User>();
		rr.setData(user);
		return rr;
		
	}
}
