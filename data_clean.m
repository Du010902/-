function output = data_clean()
data = data_input();
% 输入的数据是cell类型的，索引时用()
% 读取以小时为间隔的数据
data_hour = data.data_hour;
n = size(data_hour,1);
all_data = [];
for i = 1:20
    data_temp = [data_hour(:,[1,i + 1,22]), repmat({"flow_" + num2str(i)},n,1)];
    all_data = [all_data;data_temp];
end
% 处理all_data中的异常值，以及缺失值
% 处理异常值 ---------------------------------------------------------------
all_data = abnormal_data(all_data);
all_data = fill_nan(all_data);
all_data_temp = all_data(string(all_data(:,4)) == "flow_1",1);
for i = 1:20
    all_data_temp = [all_data_temp,all_data(string(all_data(:,4)) == "flow_" + num2str(i),2)]
end
all_data_temp = [all_data_temp,all_data(string(all_data(:,4)) == "flow_1",3)];
all_data = all_data_temp;
output.all_data = all_data;
end



% % 读取天气数据
% data_weather = data.data_weather;
% % 读取疫情数据
% data_epidemic = data.data_epidemic;
% % 填补缺失值，缺失值全部置为0
% data_temp = cell2mat(data_epidemic(:,2:8));
% data_temp = num2cell(fillmissing(data_temp,'constant',0));
% data_epidemic(:,2:8) = data_temp;
% % 将data_hour和天气数据合并
% temp = string(data_weather(:,1));
% data_temp = data_weather((year(temp) >= 2022),1:end - 1);
% temp = temp(year(temp) >= 2022);
% data_temp = data_temp((minute(temp) == 0),1:end - 1);
% data_temp = data_temp(2:end,:);
% temp = temp(minute(temp) == 0,1);
% temp = temp(2:end,:);
% data_hour = [data_hour, num2cell(repmat([nan nan nan nan nan nan],n,1))];
% count = 1;
% for i = 1:n
%     if count <= size(data_temp,1) && data_hour{i,1} == temp(count,1)
%         data_hour(i,24:29) = data_temp(count,2:7);
%         count = count + 1;
%     end
% end
% % 将data_hour和疫情信息合并
% temp = string(data_epidemic(:,1));
% data_temp = data_epidemic(year(temp) >= 2022,:);
% data_hour = [data_hour, num2cell(repmat([nan nan nan nan nan nan nan],n,1))];
% start = 1;
% for i = 1:size(data_temp,1)
%     for j = start:n
%         if year(data_temp{i,1}) == year(data_hour{j,1}) && month(data_temp{i,1}) == month(data_hour{j,1})...
%                 && day(data_temp{i,1}) == day(data_hour{j,1})
%             data_hour(j,30:36) = data_temp(i,2:8);
%         else
%             start = j;
%             break
%         end
%     end
% end
% output.data_hour = data_hour;