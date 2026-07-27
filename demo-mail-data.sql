-- ============================================================================
-- 演示邮件数据种子（Mail 页面）- 拟真分布，图表友好
-- 用户：test01, test02, test03, xm
-- 重要:域名必须为xm666.fun
-- 数量：垃圾 10 条 + 收件箱 45 条 + 已发送 46 条 = 共 101 条
-- 收件箱/垃圾：demonormXXX、demospamXXX（无下划线），避免未读计数/列表已读状态错误
-- 已发送：demosXXX（无下划线），避免趋势图/频率图误计为 1
--        仅覆盖最近 7 天，每日发送量有高有低（2～12 封/天）
-- 执行：mysql -h localhost -u mailuser -p"$(cat /etc/mail-ops/mail-db.pass)" maildb < demo-mail-data.sql
-- 支持重复执行：会先删除旧演示数据再插入
-- ============================================================================

-- 0. 清理旧演示数据（demo_*、demonorm*、demospam*、demos* 均需清理）
DELETE er FROM email_recipients er
INNER JOIN emails e ON er.email_id = e.id
WHERE e.message_id LIKE 'demo%';
DELETE FROM emails WHERE message_id LIKE 'demo%';

-- 1. 演示用户
INSERT IGNORE INTO mail_users (username, email, display_name, is_active) VALUES
('test01', 'test01@xm666.fun', 'Test User 01', 1),
('test02', 'test02@xm666.fun', 'Test User 02', 1),
('test03', 'test03@xm666.fun', 'Test User 03', 1),
('xm',     'xm@xm666.fun',     'XM Admin',      1);

-- 2. 垃圾邮件 10 条（近 3 天）
--    message_id 格式 demospamXXX（无下划线），避免 SUBSTRING_INDEX 误判
INSERT INTO emails (message_id, from_addr, to_addr, cc_addr, subject, body, html_body, date_received, date_sent, folder_id, read_status, size_bytes, headers, is_deleted) VALUES
('demospam001','noreply@spam.com','test01@xm666.fun','','限时优惠！点击领取奖金','恭喜您中奖100万！请点击链接领取。','<p>恭喜您中奖100万！请点击链接领取。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 8 HOUR),5,0,200,NULL,0),
('demospam002','admin@junk.com','test02@xm666.fun','','您的账户需要验证','请立即验证您的账户，否则将被关闭。','<p>请立即验证您的账户。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 10 HOUR),5,0,180,NULL,0),
('demospam003','info@trash.com','test03@xm666.fun','','免费礼品等你拿','点击领取免费礼品，仅限今日！','<p>点击领取免费礼品。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 14 HOUR),5,0,150,NULL,0),
('demospam004','support@fake.com','xm@xm666.fun','','紧急：您的订单异常','您的订单需要重新确认支付。','<p>您的订单需要重新确认支付。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 17 HOUR),5,0,190,NULL,0),
('demospam005','winner@lottery.com','test01@xm666.fun','','恭喜中奖','您已被选为幸运用户，点击领取奖品。','<p>点击领取奖品。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 9 HOUR),5,0,160,NULL,0),
('demospam006','service@bank-fake.com','test02@xm666.fun','','账户安全提醒','您的银行卡需重新绑定，请点击链接。','<p>请点击链接完成绑定。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 11 HOUR),5,0,170,NULL,0),
('demospam007','deals@shop.com','test03@xm666.fun','','双十一预售','爆款预售，先到先得！','<p>爆款预售，先到先得！</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 15 HOUR),5,0,140,NULL,0),
('demospam008','noreply@survey.com','xm@xm666.fun','','填写问卷送红包','完成问卷即可获得现金红包。','<p>完成问卷即可获得现金红包。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 10 HOUR),5,0,155,NULL,0),
('demospam009','promo@travel.com','test01@xm666.fun','','机票特价','国内往返机票低至99元！','<p>国内往返机票低至99元！</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 14 HOUR),5,0,165,NULL,0),
('demospam010','alert@system.com','test02@xm666.fun','','系统通知','您的账号存在异常登录，请核实。','<p>请核实并修改密码。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 16 HOUR),5,0,175,NULL,0);

-- 3. 收件箱 45 条（约 10 天，每天 2～8 封）
--    message_id 格式 demonormXXX（无下划线），避免 SUBSTRING_INDEX 将多封误判为同一封导致未读计数错误
INSERT INTO emails (message_id, from_addr, to_addr, cc_addr, subject, body, html_body, date_received, date_sent, folder_id, read_status, size_bytes, headers, is_deleted) VALUES
('demonorm001','test02@xm666.fun','test01@xm666.fun','','项目进度更新','本周项目进度已更新，请查看附件。','<p>本周项目进度已更新，请查看附件。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 8 HOUR),1,0,320,NULL,0),
('demonorm002','test03@xm666.fun','test02@xm666.fun','','会议纪要','今日会议纪要已整理完毕，请审阅。','<p>今日会议纪要已整理完毕，请审阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 9 HOUR),1,0,450,NULL,0),
('demonorm003','xm@xm666.fun','test03@xm666.fun','','系统升级通知','系统将于本周六凌晨进行升级，请提前保存工作。','<p>系统将于本周六凌晨进行升级。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 10 HOUR),1,0,280,NULL,0),
('demonorm004','test01@xm666.fun','xm@xm666.fun','','周报提交','本周周报已提交，请查收。','<p>本周周报已提交，请查收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 14 HOUR),1,0,210,NULL,0),
('demonorm005','test03@xm666.fun','test01@xm666.fun','','文档已更新','文档已更新到共享目录，请查看。','<p>文档已更新到共享目录，请查看。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 15 HOUR),1,0,190,NULL,0),
('demonorm006','xm@xm666.fun','test02@xm666.fun','','权限已开通','你的新权限已开通，可以登录系统了。','<p>你的新权限已开通。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 16 HOUR),1,0,160,NULL,0),
('demonorm007','test01@xm666.fun','test02@xm666.fun','','请查收附件','方案文档见附件，请尽快反馈。','<p>方案文档见附件，请尽快反馈。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 9 HOUR),1,0,380,NULL,0),
('demonorm008','test02@xm666.fun','xm@xm666.fun','','需求确认','新需求已整理，请确认优先级。','<p>新需求已整理，请确认优先级。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 14 HOUR),1,0,290,NULL,0),
('demonorm009','xm@xm666.fun','test01@xm666.fun','','欢迎使用 XM 邮件系统','欢迎使用本系统，如有问题请联系管理员。','<p>欢迎使用本系统。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 8 HOUR),1,0,220,NULL,0),
('demonorm010','test01@xm666.fun','test03@xm666.fun','','协作邀请','邀请你一起参与新项目协作，有空回复。','<p>邀请你一起参与新项目协作。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 9 HOUR),1,0,200,NULL,0),
('demonorm011','test02@xm666.fun','test03@xm666.fun','','反馈汇总','上周的反馈已汇总成表，见附件。','<p>上周的反馈已汇总成表，见附件。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 10 HOUR),1,0,410,NULL,0),
('demonorm012','test03@xm666.fun','xm@xm666.fun','','测试报告','本轮测试报告已提交，请审阅。','<p>本轮测试报告已提交，请审阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 11 HOUR),1,0,520,NULL,0),
('demonorm013','test02@xm666.fun','test01@xm666.fun','','回复：项目进度','收到，已看完，下周一会前再对一下细节。','<p>收到，已看完，下周一会前再对一下细节。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 14 HOUR),1,0,180,NULL,0),
('demonorm014','xm@xm666.fun','test02@xm666.fun','','季度目标确认','请确认本季度各项目标与资源分配。','<p>请确认本季度各项目标与资源分配。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 15 HOUR),1,0,350,NULL,0),
('demonorm015','test01@xm666.fun','test03@xm666.fun','','会议改期','原定周三的会议改到周四下午，请知悉。','<p>原定周三的会议改到周四下午，请知悉。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 17 HOUR),1,0,120,NULL,0),
('demonorm016','test03@xm666.fun','test01@xm666.fun','','接口文档','API 接口文档已更新，请查阅 v2 版本。','<p>API 接口文档已更新，请查阅 v2 版本。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 8 HOUR),1,0,580,NULL,0),
('demonorm017','test02@xm666.fun','xm@xm666.fun','','预算申请','Q2 预算申请已提交，请审批。','<p>Q2 预算申请已提交，请审批。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 13 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 13 HOUR),1,0,240,NULL,0),
('demonorm018','xm@xm666.fun','test03@xm666.fun','','安全培训通知','本周五下午 2 点进行全员安全培训，请准时参加。','<p>本周五下午 2 点进行全员安全培训，请准时参加。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 16 HOUR),1,0,260,NULL,0),
('demonorm019','test01@xm666.fun','test02@xm666.fun','','设计稿反馈','首页设计稿已看，有几处需要调整，见标注。','<p>首页设计稿已看，有几处需要调整，见标注。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 9 HOUR),1,0,390,NULL,0),
('demonorm020','test03@xm666.fun','test02@xm666.fun','','数据库迁移计划','拟于下周六凌晨进行 DB 迁移，请确认时间窗口。','<p>拟于下周六凌晨进行 DB 迁移，请确认时间窗口。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 11 HOUR),1,0,310,NULL,0),
('demonorm021','test02@xm666.fun','test01@xm666.fun','','报销单','上月差旅报销单已提交，请审批。','<p>上月差旅报销单已提交，请审批。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 14 HOUR),1,0,150,NULL,0),
('demonorm022','xm@xm666.fun','test01@xm666.fun','','VPN 权限','已为你开通 VPN，账号见附件说明。','<p>已为你开通 VPN，账号见附件说明。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 15 HOUR),1,0,280,NULL,0),
('demonorm023','test01@xm666.fun','xm@xm666.fun','','故障说明','昨日 14:00 左右的访问异常已定位，为 CDN 节点故障。','<p>昨日 14:00 左右的访问异常已定位，为 CDN 节点故障。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 16 HOUR),1,0,320,NULL,0),
('demonorm024','test03@xm666.fun','test02@xm666.fun','','代码合并','feature/login 已合并到 develop，请拉取最新代码。','<p>feature/login 已合并到 develop，请拉取最新代码。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 9 HOUR),1,0,170,NULL,0),
('demonorm025','test02@xm666.fun','test03@xm666.fun','','排期表','本月排期表已更新，请同步到本地。','<p>本月排期表已更新，请同步到本地。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 10 HOUR),1,0,210,NULL,0),
('demonorm026','xm@xm666.fun','test02@xm666.fun','','值班表','下周值班表已排好，请查收。','<p>下周值班表已排好，请查收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 14 HOUR),1,0,140,NULL,0),
('demonorm027','test01@xm666.fun','test03@xm666.fun','','团建提议','建议下月组织一次团建，大家投票选地点吧。','<p>建议下月组织一次团建，大家投票选地点吧。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 17 HOUR),1,0,190,NULL,0),
('demonorm028','test03@xm666.fun','xm@xm666.fun','','性能报告','上周性能压测报告已出，整体达标。','<p>上周性能压测报告已出，整体达标。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 8 HOUR),1,0,440,NULL,0),
('demonorm029','test02@xm666.fun','test01@xm666.fun','','合同草稿','供应商合同草稿已发，请法务过目。','<p>供应商合同草稿已发，请法务过目。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 9 HOUR),1,0,520,NULL,0),
('demonorm030','xm@xm666.fun','test03@xm666.fun','','年度总结','请各位在本周五前提交个人年度总结。','<p>请各位在本周五前提交个人年度总结。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 10 HOUR),1,0,230,NULL,0),
('demonorm031','test01@xm666.fun','test02@xm666.fun','','面试安排','候选人张三周四 10:00 面试，请参与评审。','<p>候选人张三周四 10:00 面试，请参与评审。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 11 HOUR),1,0,180,NULL,0),
('demonorm032','test03@xm666.fun','test01@xm666.fun','','环境说明','测试环境已就绪，地址与账号见内文。','<p>测试环境已就绪，地址与账号见内文。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 14 HOUR),1,0,260,NULL,0),
('demonorm033','test02@xm666.fun','xm@xm666.fun','','采购清单','办公用品采购清单已整理，请批一下。','<p>办公用品采购清单已整理，请批一下。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 15 HOUR),1,0,195,NULL,0),
('demonorm034','xm@xm666.fun','test01@xm666.fun','','制度更新','考勤制度已更新，请阅读并遵守。','<p>考勤制度已更新，请阅读并遵守。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 16 HOUR),1,0,370,NULL,0),
('demonorm035','test01@xm666.fun','test03@xm666.fun','','技术分享','下周三技术分享主题：微服务实践，欢迎参加。','<p>下周三技术分享主题：微服务实践，欢迎参加。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 8 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 8 DAY),INTERVAL 10 HOUR),1,0,220,NULL,0),
('demonorm036','test03@xm666.fun','test02@xm666.fun','','依赖升级','建议将 Redis 升级至 6.x，已写迁移方案。','<p>建议将 Redis 升级至 6.x，已写迁移方案。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 8 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 8 DAY),INTERVAL 14 HOUR),1,0,410,NULL,0),
('demonorm037','test02@xm666.fun','test01@xm666.fun','','客户反馈','客户 A 对最新版本表示满意，已记录。','<p>客户 A 对最新版本表示满意，已记录。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 9 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 9 DAY),INTERVAL 9 HOUR),1,0,160,NULL,0),
('demonorm038','xm@xm666.fun','test02@xm666.fun','','假期安排','国庆值班与调休安排见附件。','<p>国庆值班与调休安排见附件。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 9 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 9 DAY),INTERVAL 15 HOUR),1,0,290,NULL,0),
('demonorm039','test01@xm666.fun','xm@xm666.fun','','周会纪要','本周周会纪要已整理，请查阅。','<p>本周周会纪要已整理，请查阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 8 HOUR),1,0,250,NULL,0),
('demonorm040','test03@xm666.fun','test01@xm666.fun','','Bug 修复','#1234 已修复并部署到预发，请验收。','<p>#1234 已修复并部署到预发，请验收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 11 HOUR),1,0,170,NULL,0),
('demonorm041','test02@xm666.fun','test03@xm666.fun','','需求评审','新需求评审定于明天 15:00，请准时参加。','<p>新需求评审定于明天 15:00，请准时参加。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 13 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 13 HOUR),1,0,200,NULL,0),
('demonorm042','xm@xm666.fun','test03@xm666.fun','','证书续期','服务器 SSL 证书将于下月到期，请安排续期。','<p>服务器 SSL 证书将于下月到期，请安排续期。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 15 HOUR),1,0,280,NULL,0),
('demonorm043','test01@xm666.fun','xm@xm666.fun','','资料汇总','你要的行业资料已汇总到网盘，链接见内文。','<p>你要的行业资料已汇总到网盘，链接见内文。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 17 HOUR),1,0,330,NULL,0),
('demonorm044','test03@xm666.fun','xm@xm666.fun','','上线检查单','本次上线检查单已填写完毕，请审批。','<p>本次上线检查单已填写完毕，请审批。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 9 HOUR),1,0,190,NULL,0),
('demonorm045','test02@xm666.fun','xm@xm666.fun','','转正申请','我的转正申请已提交，请查收并安排面谈。','<p>我的转正申请已提交，请查收并安排面谈。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 16 HOUR),1,0,210,NULL,0);

-- 4. 已发送 46 条（仅最近 7 天，每日发送量有高有低：8/2/12/5/3/10/6 封）
--    说明：message_id 使用 demosXXX 格式（无下划线），避免 SUBSTRING_INDEX(message_id,'_',1) 将多封邮件误计为 1
--    分布：7天前8封、6天前2封、5天前12封、4天前5封、3天前3封、2天前10封、1天前6封
INSERT INTO emails (message_id, from_addr, to_addr, cc_addr, subject, body, html_body, date_received, date_sent, folder_id, read_status, size_bytes, headers, is_deleted) VALUES
('demos001','test01@xm666.fun','test02@xm666.fun','','会议时间确认','明天下午三点的会议请准时参加。','<p>明天下午三点的会议请准时参加。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 8 HOUR),2,0,150,NULL,0),
('demos002','test02@xm666.fun','test03@xm666.fun','','资料已发','你要的资料已发到邮箱，请查收。','<p>你要的资料已发到邮箱，请查收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 9 HOUR),2,0,170,NULL,0),
('demos003','test03@xm666.fun','xm@xm666.fun','','问题汇总','本周遇到的问题已汇总，请过目。','<p>本周遇到的问题已汇总，请过目。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 10 HOUR),2,0,310,NULL,0),
('demos004','xm@xm666.fun','test01@xm666.fun','','配置说明','系统配置说明文档已更新，请查阅。','<p>系统配置说明文档已更新，请查阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 11 HOUR),2,0,260,NULL,0),
('demos005','test01@xm666.fun','test03@xm666.fun','','周末加班安排','周六上午需要加班赶进度，能来吗？','<p>周六上午需要加班赶进度，能来吗？</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 14 HOUR),2,0,140,NULL,0),
('demos006','test02@xm666.fun','xm@xm666.fun','','申请权限','需要申请报表导出权限，谢谢。','<p>需要申请报表导出权限，谢谢。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 15 HOUR),2,0,130,NULL,0),
('demos007','test03@xm666.fun','test01@xm666.fun','','代码评审邀请','有空帮忙评审一下 PR 吗？','<p>有空帮忙评审一下 PR 吗？</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 16 HOUR),2,0,120,NULL,0),
('demos008','xm@xm666.fun','test02@xm666.fun','','备份提醒','请定期备份重要数据，有疑问可联系我。','<p>请定期备份重要数据，有疑问可联系我。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 7 DAY),INTERVAL 17 HOUR),2,0,195,NULL,0),
('demos009','test01@xm666.fun','xm@xm666.fun','','故障报告','今早发现登录缓慢，已记录现象。','<p>今早发现登录缓慢，已记录现象。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 9 HOUR),2,0,175,NULL,0),
('demos010','test02@xm666.fun','test01@xm666.fun','','项目进度更新','本周进度已更新，请查看。','<p>本周进度已更新，请查看。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 14 HOUR),2,0,165,NULL,0),
('demos011','test03@xm666.fun','test02@xm666.fun','','会议纪要','今日会议纪要已发，请查收。','<p>今日会议纪要已发，请查收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 8 HOUR),2,0,230,NULL,0),
('demos012','xm@xm666.fun','test03@xm666.fun','','安全策略更新','安全策略已更新，请务必阅读并遵守。','<p>安全策略已更新，请务必阅读并遵守。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 9 HOUR),2,0,340,NULL,0),
('demos013','test02@xm666.fun','test03@xm666.fun','','排期确认','下月排期请确认后回复。','<p>下月排期请确认后回复。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 10 HOUR),2,0,110,NULL,0),
('demos014','test01@xm666.fun','test02@xm666.fun','','需求文档','新需求文档已写好，请评审。','<p>新需求文档已写好，请评审。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 11 HOUR),2,0,380,NULL,0),
('demos015','test03@xm666.fun','xm@xm666.fun','','资源申请','需要申请一台测试机，配置见内文。','<p>需要申请一台测试机，配置见内文。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 14 HOUR),2,0,200,NULL,0),
('demos016','xm@xm666.fun','test01@xm666.fun','','培训资料','入职培训资料已更新到知识库。','<p>入职培训资料已更新到知识库。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 15 HOUR),2,0,420,NULL,0),
('demos017','test02@xm666.fun','test03@xm666.fun','','联调时间','接口联调暂定周三下午，有问题随时说。','<p>接口联调暂定周三下午，有问题随时说。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 16 HOUR),2,0,150,NULL,0),
('demos018','test01@xm666.fun','test03@xm666.fun','','会议室预订','已预订明天 14:00 的 3 号会议室。','<p>已预订明天 14:00 的 3 号会议室。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 17 HOUR),2,0,130,NULL,0),
('demos019','test03@xm666.fun','test02@xm666.fun','','部署说明','v1.2 部署说明与回滚步骤见附件。','<p>v1.2 部署说明与回滚步骤见附件。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 8 HOUR),2,0,360,NULL,0),
('demos020','xm@xm666.fun','test02@xm666.fun','','考核指标','本季度考核指标已下发，请知悉。','<p>本季度考核指标已下发，请知悉。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 13 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 13 HOUR),2,0,270,NULL,0),
('demos021','test02@xm666.fun','test01@xm666.fun','','日报汇总','本周日报已汇总，请查阅。','<p>本周日报已汇总，请查阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 8 HOUR),2,0,190,NULL,0),
('demos022','test01@xm666.fun','xm@xm666.fun','','风险提示','当前项目存在延期风险，建议加人。','<p>当前项目存在延期风险，建议加人。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 5 DAY),INTERVAL 14 HOUR),2,0,220,NULL,0),
('demos023','test03@xm666.fun','test01@xm666.fun','','依赖说明','新加依赖的 license 已核对，无问题。','<p>新加依赖的 license 已核对，无问题。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 9 HOUR),2,0,180,NULL,0),
('demos024','test02@xm666.fun','xm@xm666.fun','','出差申请','下周一至周三出差客户现场，请审批。','<p>下周一至周三出差客户现场，请审批。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 10 HOUR),2,0,210,NULL,0),
('demos025','xm@xm666.fun','test03@xm666.fun','','合规检查','合规检查清单已发，请各部门对照执行。','<p>合规检查清单已发，请各部门对照执行。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 14 HOUR),2,0,310,NULL,0),
('demos026','test01@xm666.fun','test02@xm666.fun','','设计评审','UI 设计稿已上传，请明天前反馈。','<p>UI 设计稿已上传，请明天前反馈。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 15 HOUR),2,0,290,NULL,0),
('demos027','test03@xm666.fun','test02@xm666.fun','','监控告警','昨晚的告警已处理，原因见内文。','<p>昨晚的告警已处理，原因见内文。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 16 HOUR),2,0,250,NULL,0),
('demos028','test02@xm666.fun','test01@xm666.fun','','合同会签','采购合同需你会签，请尽快处理。','<p>采购合同需你会签，请尽快处理。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 9 HOUR),2,0,170,NULL,0),
('demos029','xm@xm666.fun','test01@xm666.fun','','福利通知','年度体检安排已出，请查收附件。','<p>年度体检安排已出，请查收附件。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 10 HOUR),2,0,240,NULL,0),
('demos030','test01@xm666.fun','test03@xm666.fun','','技术方案','新模块技术方案已写完，请评审。','<p>新模块技术方案已写完，请评审。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 3 DAY),INTERVAL 14 HOUR),2,0,480,NULL,0),
('demos031','test03@xm666.fun','xm@xm666.fun','','上线报告','上周上线总结与问题已整理，请阅。','<p>上周上线总结与问题已整理，请阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 8 HOUR),2,0,320,NULL,0),
('demos032','test02@xm666.fun','test03@xm666.fun','','数据备份','重要数据已备份至备份机，请知悉。','<p>重要数据已备份至备份机，请知悉。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 9 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 9 HOUR),2,0,160,NULL,0),
('demos033','xm@xm666.fun','test02@xm666.fun','','制度修订','报销制度有修订，请阅读新版本。','<p>报销制度有修订，请阅读新版本。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 10 HOUR),2,0,280,NULL,0),
('demos034','test01@xm666.fun','test02@xm666.fun','','测试用例','新增用例已补充到用例库，请同步。','<p>新增用例已补充到用例库，请同步。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 11 HOUR),2,0,390,NULL,0),
('demos035','test02@xm666.fun','xm@xm666.fun','','招聘进度','后端岗位已有候选人进入二面，同步一下。','<p>后端岗位已有候选人进入二面，同步一下。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 14 HOUR),2,0,200,NULL,0),
('demos036','test03@xm666.fun','test01@xm666.fun','','环境恢复','预发环境已恢复，可以继续联调。','<p>预发环境已恢复，可以继续联调。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 15 HOUR),2,0,180,NULL,0),
('demos037','xm@xm666.fun','test03@xm666.fun','','项目复盘','请各项目负责人周五前提交复盘报告。','<p>请各项目负责人周五前提交复盘报告。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 16 HOUR),2,0,260,NULL,0),
('demos038','test01@xm666.fun','xm@xm666.fun','','周报','本周工作周报已提交，请查收。','<p>本周工作周报已提交，请查收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 17 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 17 HOUR),2,0,230,NULL,0),
('demos039','test03@xm666.fun','test02@xm666.fun','','依赖发布','common-utils 2.0 已发布到私服，请升级。','<p>common-utils 2.0 已发布到私服，请升级。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 8 HOUR),2,0,190,NULL,0),
('demos040','test02@xm666.fun','test01@xm666.fun','','客户会议','下周二客户会议议程已发，请准备。','<p>下周二客户会议议程已发，请准备。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 13 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 13 HOUR),2,0,270,NULL,0),
('demos041','test01@xm666.fun','test02@xm666.fun','','会议时间确认','明天下午三点的会议请准时参加。','<p>明天下午三点的会议请准时参加。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 8 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 8 HOUR),2,0,150,NULL,0),
('demos042','test02@xm666.fun','test03@xm666.fun','','资料已发','你要的资料已发到邮箱，请查收。','<p>你要的资料已发到邮箱，请查收。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 10 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 10 HOUR),2,0,170,NULL,0),
('demos043','test03@xm666.fun','xm@xm666.fun','','问题汇总','本周遇到的问题已汇总，请过目。','<p>本周遇到的问题已汇总，请过目。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 11 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 11 HOUR),2,0,310,NULL,0),
('demos044','xm@xm666.fun','test01@xm666.fun','','配置说明','系统配置说明文档已更新，请查阅。','<p>系统配置说明文档已更新，请查阅。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 14 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 14 HOUR),2,0,260,NULL,0),
('demos045','test01@xm666.fun','test03@xm666.fun','','周末加班安排','周六上午需要加班赶进度，能来吗？','<p>周六上午需要加班赶进度，能来吗？</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 15 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 15 HOUR),2,0,140,NULL,0),
('demos046','test02@xm666.fun','xm@xm666.fun','','申请权限','需要申请报表导出权限，谢谢。','<p>需要申请报表导出权限，谢谢。</p>',DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 16 HOUR),DATE_ADD(DATE_SUB(NOW(),INTERVAL 1 DAY),INTERVAL 16 HOUR),2,0,130,NULL,0);

-- 5. 收件人表（收件箱依赖此表，含 demonorm*、demospam*、demos*）
INSERT INTO email_recipients (email_id, recipient_type, email_address, is_read)
SELECT e.id, 'to', e.to_addr, COALESCE(e.read_status, 0)
FROM emails e
WHERE e.message_id LIKE 'demo%';
