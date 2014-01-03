SGActionView
============

##介绍

SGActionView提供三种弹出视图:  

* SGAlertMenu，类似于UIAlertView的提示框。    
![alert](https://raw.github.com/sagiwei/SGActionView/master/alert.png)
* SGGridMenu，多用于选择服务、分享等操作，类似UIActivityViewController的功能  
![grid](https://raw.github.com/sagiwei/SGActionView/master/grid.png)
* SGSheetMenu，一个选项列表，可以设置默认值。    
![sheet](https://raw.github.com/sagiwei/SGActionView/master/sheet.png)

##使用

引入`SGActionView.h`  

提示框：  
	
	[SGActionView showAlertWithTitle:@"Title"
	                         message:@"Message"
	                     buttonTitle:@"Cancel"
	                  selectedHandle:nil];	

选项列表：  
	
	[SGActionView showSheetWithTitle:@"Sheet View"
	                	   itemTitles:@[ @"Wedding Bell", @"I'm Yours", @"When I was your mam" ]
	                   itemSubTitles:@[ @"Depapepe - Let's go!!!", @"Jason Mraz", @"Bruno Mars" ]
	                   selectedIndex:0
	                  selectedHandle:nil];
	                
分享：  
	
	[SGActionView showGridMenuWithTitle:@"Grid View"
	                         itemTitles:@[ @"Facebook", @"Twitter", @"Google+", @"Linkedin",
	                                       @"weibo", @"wechat", @"Pocket", @"Dropbox" ]
	                             images:@[ [UIImage imageNamed:@"facebook"],
	                                       [UIImage imageNamed:@"twitter"],
	                                       [UIImage imageNamed:@"googleplus"],
	                                       [UIImage imageNamed:@"linkedin"],
	                                       [UIImage imageNamed:@"weibo"],
	                                       [UIImage imageNamed:@"wechat"],
	                                       [UIImage imageNamed:@"pocket"],
	                                       [UIImage imageNamed:@"dropbox"]]
	                     selectedHandle:nil];