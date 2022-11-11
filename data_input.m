function data = data_input()
clear;clc
data.data_day = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\daily_dataset.csv'));
data.data_hour = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\hourly_dataset.csv'));
data.data_per5min = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\per5min_dataset.csv'));
data.data_weather = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\weather.csv'));
data.data_epidemic = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\epidemic.csv'));
data.data_test = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\test_public.csv'));
data.data_sample = table2cell(readtable('D:\xiangmu\pycharm\机器学习实验\居民小区二次用水预测\training_dataset\sample_submission.csv'));
end