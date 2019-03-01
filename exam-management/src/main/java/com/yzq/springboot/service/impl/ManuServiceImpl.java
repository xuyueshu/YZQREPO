package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.Attributes;
import com.yzq.springboot.bean.Manu;
import com.yzq.springboot.mapper.ManuMapper;
import com.yzq.springboot.service.IManuService;
@Service("manuService")
public class ManuServiceImpl implements IManuService {
	@Autowired
	private ManuMapper manuMapper;

	@Override
	public List<Manu> getManuList(Integer userId) {
		List<Manu> manu=manuMapper.getParentManu(userId);
		for (Manu parentManu : manu) {
			parentManu.setAttributes(new Attributes(parentManu.getUrl()));
			Integer parentId=parentManu.getId();
			List<Manu> children=manuMapper.getChildrenManueByPid(parentId);
			for (Manu child : children) {
				child.setAttributes(new Attributes(child.getUrl()));
			}
			parentManu.setChildren(children);
		}
		return manu;
	}

}
