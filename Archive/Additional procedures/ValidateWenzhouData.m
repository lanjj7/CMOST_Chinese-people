%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     CMOST: Colon Modeling with Open Source Tool
%     温州ADR数据验证和可视化函数
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ValidateWenzhouData()
% 验证温州数据的完整性和合理性，并生成可视化报告

fprintf('========================================\n');
fprintf('    温州ADR数据验证报告\n');
fprintf('========================================\n');
fprintf('日期: %s\n\n', datestr(now));

%% 1. 加载数据
handles.Variables.Benchmarks = struct();
handles = Default_Benchmarks(handles);
BM = handles.Variables.Benchmarks;

%% 2. 验证早期腺瘤数据
fprintf('==== 早期腺瘤 (Non-Advanced Adenoma) ====\n');
fprintf('\nOverall:\n');
fprintf('年龄: '); fprintf('%d ', BM.EarlyPolyp.Ov_y); fprintf('\n');
fprintf('ADR%%: '); fprintf('%.2f ', BM.EarlyPolyp.Ov_perc); fprintf('\n');
checkMonotonicity(BM.EarlyPolyp.Ov_perc, 'Overall早期腺瘤');

fprintf('\nMale:\n');
fprintf('年龄: '); fprintf('%d ', BM.EarlyPolyp.Male_y); fprintf('\n');
fprintf('ADR%%: '); fprintf('%.2f ', BM.EarlyPolyp.Male_perc); fprintf('\n');
checkMonotonicity(BM.EarlyPolyp.Male_perc, 'Male早期腺瘤');

fprintf('\nFemale:\n');
fprintf('年龄: '); fprintf('%d ', BM.EarlyPolyp.Female_y); fprintf('\n');
fprintf('ADR%%: '); fprintf('%.2f ', BM.EarlyPolyp.Female_perc); fprintf('\n');
checkMonotonicity(BM.EarlyPolyp.Female_perc, 'Female早期腺瘤');

%% 3. 验证进展期腺瘤数据
fprintf('\n==== 进展期腺瘤 (Advanced Adenoma) ====\n');
fprintf('\nOverall:\n');
fprintf('年龄: '); fprintf('%d ', BM.AdvPolyp.Ov_y); fprintf('\n');
fprintf('ADR%%: '); fprintf('%.2f ', BM.AdvPolyp.Ov_perc); fprintf('\n');
checkMonotonicity(BM.AdvPolyp.Ov_perc, 'Overall进展期腺瘤');

fprintf('\nMale:\n');
fprintf('年龄: '); fprintf('%d ', BM.AdvPolyp.Male_y); fprintf('\n');
fprintf('ADR%%: '); fprintf('%.2f ', BM.AdvPolyp.Male_perc); fprintf('\n');
checkMonotonicity(BM.AdvPolyp.Male_perc, 'Male进展期腺瘤');

fprintf('\nFemale:\n');
fprintf('年龄: '); fprintf('%d ', BM.AdvPolyp.Female_y); fprintf('\n');
fprintf('ADR%%: '); fprintf('%.2f ', BM.AdvPolyp.Female_perc); fprintf('\n');
checkMonotonicity(BM.AdvPolyp.Female_perc, 'Female进展期腺瘤');

%% 4. 可视化
figure('Name', '温州ADR数据验证', 'Position', [100, 100, 1200, 800]);

% 早期腺瘤
subplot(2,3,1);
plot(BM.EarlyPolyp.Ov_y, BM.EarlyPolyp.Ov_perc, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
plot(BM.EarlyPolyp.Male_y, BM.EarlyPolyp.Male_perc, 'r--s', 'LineWidth', 1.5, 'MarkerSize', 6);
plot(BM.EarlyPolyp.Female_y, BM.EarlyPolyp.Female_perc, 'g-.^', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('年龄'); ylabel('ADR (%)');
title('早期腺瘤检出率');
legend('Overall', 'Male', 'Female', 'Location', 'northwest');
grid on;

% 进展期腺瘤
subplot(2,3,2);
plot(BM.AdvPolyp.Ov_y, BM.AdvPolyp.Ov_perc, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
plot(BM.AdvPolyp.Male_y, BM.AdvPolyp.Male_perc, 'r--s', 'LineWidth', 1.5, 'MarkerSize', 6);
plot(BM.AdvPolyp.Female_y, BM.AdvPolyp.Female_perc, 'g-.^', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('年龄'); ylabel('ADR (%)');
title('进展期腺瘤检出率');
legend('Overall', 'Male', 'Female', 'Location', 'northwest');
grid on;

% 进展期占比
subplot(2,3,3);
adv_ratio = BM.AdvPolyp.Ov_perc ./ (BM.EarlyPolyp.Ov_perc + BM.AdvPolyp.Ov_perc) * 100;
plot(BM.AdvPolyp.Ov_y, adv_ratio, 'k-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('年龄'); ylabel('进展期占比 (%)');
title('进展期腺瘤占比');
grid on;

% 性别差异 - 早期
subplot(2,3,4);
male_female_ratio_early = BM.EarlyPolyp.Male_perc ./ BM.EarlyPolyp.Female_perc;
plot(BM.EarlyPolyp.Ov_y, male_female_ratio_early, 'm-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('年龄'); ylabel('男/女比值');
title('早期腺瘤性别差异');
yline(1, '--k', '无差异');
grid on;

% 性别差异 - 进展期
subplot(2,3,5);
male_female_ratio_adv = BM.AdvPolyp.Male_perc ./ BM.AdvPolyp.Female_perc;
plot(BM.AdvPolyp.Ov_y, male_female_ratio_adv, 'm-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('年龄'); ylabel('男/女比值');
title('进展期腺瘤性别差异');
yline(1, '--k', '无差异');
grid on;

% 相对危险度
subplot(2,3,6);
bar(BM.Rel_Danger);
xlabel('时间段 (30-39, 40-49, 50-59, 60-69, 70-79, 80+)');
ylabel('进展期腺瘤占比 (%)');
title('相对危险度 (Rel\_Danger)');
grid on;

sgtitle('温州ADR数据验证 - 经标准化和异常值处理', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n========================================\n');
fprintf('    验证完成\n');
fprintf('========================================\n');

end

%% 辅助函数：检查单调性
function checkMonotonicity(data, name)
    violations = 0;
    for i = 2:length(data)
        if data(i) < data(i-1)
            violations = violations + 1;
            fprintf('  ⚠ 警告: 第%d点(%.2f) < 第%d点(%.2f)\n', i, data(i), i-1, data(i-1));
        end
    end
    if violations == 0
        fprintf('  ✓ %s: 单调性检查通过\n', name);
    else
        fprintf('  ✗ %s: 发现%d处单调性违反\n', name, violations);
    end
end
