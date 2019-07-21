package com.sunmnet.spider.ui;

import com.sunmnet.spider.utils.FileOperatorUtil;

import java.util.List;

/*复制爬虫系统对外的接口与实现*/
public class UIManager {
    /*拿到种子*/
    public static String getSeedUrl(){
        return "http://news.youth.cn/gn/";
    }

    public static List<String> getSeedUrlFromFile() throws Exception {
        String seedFilePath="seeds.txt";
        String charset="UTF-8";
        List<String> seedUrlList=FileOperatorUtil.getSeedsListFromFile(seedFilePath,charset);

        return seedUrlList;
    }
}
