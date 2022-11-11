function data = abnormal_data(all_data)
% 获取train数据\
train_temp = all_data(string(all_data(:,3)) == 'train',:);
data_ = [train_temp,num2cell(zeros(size(train_temp,1),10))];
% 按照小区、月、小时进行分组，计算每一组水流量的标准差以及平均值quantile
% 取出时间
time_temp = string(data_(:,1));
for i = 1:5064:size(data_,1)  %  遍历20个小区
     for j = 1:8  % 遍历8个月份
         month_time = time_temp(month(time_temp(i:i+5063)) == j);  % 找到了第i个小区，第j个月份的用水量
         % 找到原来的位置的方式就是：month_time + i - 1
         for k = 1:24 % 遍历24个小时
             hour_time = month_time(hour(month_time(:,1)) == mod(k,24));  % 某个特定小区
             % 特定月份中的特定小时是hour_time
             % 计算水流量的标准差
             t = size(hour_time,1);
             pos = zeros(t,1);
             area_time = (i+5063)/5064;
             for p = 1:t
                 area_temp = find(time_temp == hour_time(p));
                 pos(p) = area_temp(area_time);
             end
             flow_temp = cell2mat(data_(pos,2));
             data_(pos,[5,6,7,8]) = num2cell(repmat([std(flow_temp), ...
                 mean(flow_temp),quantile(flow_temp,0.25),quantile(flow_temp,0.75)],size(pos,1),1));
         end
     end
end
% 计算出上限和下限 data_的5、6、7、8分别是std,mean,1/4分位数，3/4分位数
com_temp = cell2mat(data_(:,[5 6 7 8]));
% 9--:lower_1
data_(:,9) = num2cell(com_temp(:,2) - 3*com_temp(:,1));
% 10--:upper_1
data_(:,10) = num2cell(com_temp(:,2) + 3*com_temp(:,1));
% 11--:lower_2
data_(:,11) = num2cell(com_temp(:,3) - 1.5*com_temp(:,4));
% 12--:upper_2
data_(:,12) = num2cell(com_temp(:,3) + 1.5*com_temp(:,4));
% 13--:lower
data_(:,13) = num2cell(max(cell2mat(data_(:,[9,11])),[],2));
% 14--:upper
data_(:,14) = num2cell(min(cell2mat(data_(:,[10,12])),[],2));
% 确定超出范围的值
com_temp = cell2mat(data_(:,[2,13,14]));
flow_temp = com_temp(:,1);
flow_temp(com_temp(:,1) > com_temp(:,3)) = nan;
flow_temp(com_temp(:,1) < com_temp(:,2)) = nan;
all_data(string(all_data(:,3)) == 'train', 2) = num2cell(flow_temp);
data = all_data;
end