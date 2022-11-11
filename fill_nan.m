function data = fill_nan(all_data)
% 获取train数据\
train_temp = all_data(string(all_data(:,3)) == 'train',:);
data_ = [train_temp,num2cell(zeros(size(train_temp,1),10))];
data_temp = fillmissing(cell2mat(data_(:,2)),'movmean',30);
% data_temp = fillmissing(data_temp,'movmean',28);
all_data(string(all_data(:,3)) == 'train', 2) = num2cell(data_temp);
data = all_data;
end