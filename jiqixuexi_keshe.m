clear;clc
%% 数据导入，整理过的数据
% all_data = data_clean();
all_data = load('all_data_new.mat').all_data_temp;
% 增加23:month、24:dayofwork、25:sin_hour、26:cos_jour这几列
date_temp = string(all_data(:,1));
hour_temp = hour(date_temp);
all_data = [all_data,num2cell([month(date_temp),day(datetime(date_temp),'dayofweek'),...
    sin(2*pi*hour_temp/24),cos(2*pi*hour_temp/24)])];
% 获取训练集数据
% 首先获取1-1到5-1号的数据集2022-01-01 01:00:00（1）  --  2022-05-01 00:00:00（2880）
data = cell2mat(all_data(1:2880,2:21));
data = [data,cell2mat(all_data(1:2880,23:26))];
% 获取训练集 1 - 2304 测试集2305：end
numtimestepsTrain = 2034;
dataTrain = data(1:numtimestepsTrain,:);
dataTrain = dataTrain(1000:end,:);
dataTest = data(numtimestepsTrain+1:end,:);
% 数据的标准化处理
mu = mean(dataTrain);
sig = std(dataTrain);
dataTrainStandardized = (dataTrain - repmat(mu,size(dataTrain,1),1)) ./ repmat(sig,size(dataTrain,1),1);
mu = mean(dataTest);
sig = std(dataTest);
dataTestStandardized = (dataTest - repmat(mu,size(dataTest,1),1)) ./ repmat(sig,size(dataTest,1),1);
% 准备预测变量和响应
rmse = [];
mlse = [];
for i = 1:20  % 遍历这20个小区
    disp(['第 ' num2str(i) ' 轮-------------------------------------------------------'])
    XTrain = dataTrainStandardized(1:end - 1,[i 21 22 23 24])';
    YTrain = dataTrainStandardized(2:end,[i 21 22 23 24])';
    % 定义LSTM框架
    numFeatures = 5;  % 5个输入
    numReaponses = 1;  % 1个输出
    numHiddenUnits = 8; % 隐藏层的个数是200
    layers = [ ...
        sequenceInputLayer(numFeatures)
        lstmLayer(numHiddenUnits)
        fullyConnectedLayer(numReaponses)
        regressionLayer
        ];
    % 指定训练选项。将求解器设置为'adam'并进行250战轮训练。要防止梯度爆炸，
    % 请将梯度阈值设置为1。指定初始学习率0.0O5，在125轮训练后通过乘以因子0.2来降低学习率。

    options = trainingOptions('adam',... % 梯度下降法
        'MaxEpochs',300, ...              % 最大迭代次数
        'GradientThreshold',1, ...       % 梯度阈值
        'InitialLearnRate',0.001);

    % 进行训练
    net = trainNetwork(XTrain,YTrain(1,:),layers,options);

    % 预测将来的时间步
    XTest = dataTestStandardized(1:end - 1,[i 21 22 23 24])';
    [net,~] = predictAndUpdateState(net,XTrain);  % 预测并更新神经网络
    YPred = dataTestStandardized(1:end,[i 21 22 23 24])';
    [net,YPred(1,1)] = predictAndUpdateState(net,YTrain(1:end,end));  %将YTrain的最后一个值代入，得到第一个预测值
    numtimestepsTest = size(XTest,2);  % 统计XTest中元素的个数，以确定需要预测几个值
    for j = 2:numtimestepsTest  % 第一个值是已经预测过的
        [net,YPred(1,j)] = predictAndUpdateState(net,YPred(:,j - 1),'ExecutionEnvironment','cpu');
    end

    % 使用先前计算的参数对预测去标准化
    YPred(1,:) = sig(i) * YPred(1,:) + mu(i);
    YPred(2:5,:) = repmat(sig(21:24)',1,size(YPred,2)).*YPred(2:5,:) + repmat(mu(21:24)',1,size(YPred,2));
    YTest = dataTest(1:end,[i 21 22 23 24])';
    rmse_temp = sqrt(mean((YPred(1,:) - YTest(1,:)).^2));  % 计算出rmse的值 : 方差
    rmse = [rmse,rmse_temp];
    mlse_temp = mean((log(1 + YPred(1,:)) - log(1 + YTest(1,:))).^2);
    mlse = [mlse,mlse_temp];
end
score = 1/(1+mean(mlse));
disp(['得分 = ',num2str(score)])
disp(['MSLE = ', num2str(mlse)])


%% 作图

% 画图，将预测值与测试数据进行比较
figure
plot(YPred(1,600:end))
hold on
plot(YTest(1,600:end),'-')
hold off
legend(["预测值","真实值"])
xlabel("样本")
title("测试集")








