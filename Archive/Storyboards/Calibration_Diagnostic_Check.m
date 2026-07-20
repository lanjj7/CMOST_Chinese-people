%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     CMOST: 校准诊断检查脚本
%     用于验证 Auto_Calibration_Step_2 的数值稳定性
%
%     使用方法：在 CMOST_Main GUI 打开后运行此脚本
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Calibration_Diagnostic_Check()

fprintf('\n=== CMOST 校准诊断检查 ===\n\n');

% 获取当前 Variables 设置
try
    handles.Variables = get(0, 'userdata');
    fprintf('✓ 成功读取 Variables 设置\n');
catch ME
    fprintf('✗ 错误：无法读取 Variables 设置\n');
    fprintf('  请先在 CMOST_Main GUI 中加载设置\n');
    return;
end

% 检查关键参数
fprintf('\n--- 关键参数检查 ---\n');
fprintf('模拟人数: %d\n', handles.Variables.Number_patients);
fprintf('随机种子: %d\n', handles.Variables.RandomSeed);

% 检查 Benchmark 数据
fprintf('\n--- Benchmark 数据检查 ---\n');
if isfield(handles.Variables, 'Benchmarks') && isfield(handles.Variables.Benchmarks, 'AdvPolyp')
    fprintf('✓ AdvPolyp Benchmarks 存在\n');
    fprintf('  Overall: %d 个数据点\n', length(handles.Variables.Benchmarks.AdvPolyp.Ov_y));
    fprintf('  Male:    %d 个数据点\n', length(handles.Variables.Benchmarks.AdvPolyp.Male_y));
    fprintf('  Female:  %d 个数据点\n', length(handles.Variables.Benchmarks.AdvPolyp.Female_y));
    
    % 检查是否有零值或过小的 benchmark
    min_ov = min(handles.Variables.Benchmarks.AdvPolyp.Ov_perc);
    if min_ov < 1e-6
        fprintf('  ⚠ 警告：Overall benchmark 中存在接近零的值 (%.2e)\n', min_ov);
    end
else
    fprintf('✗ 错误：Benchmark 数据缺失或不完整\n');
end

% 检查进展率参数
fprintf('\n--- 进展率参数检查 ---\n');
if isfield(handles.Variables, 'EarlyProgressionRate')
    fprintf('✓ EarlyProgressionRate 存在 (%d 个值)\n', length(handles.Variables.EarlyProgressionRate));
    min_rate = min(handles.Variables.EarlyProgressionRate);
    max_rate = max(handles.Variables.EarlyProgressionRate);
    fprintf('  范围: [%.6f, %.6f]\n', min_rate, max_rate);
    
    if any(~isfinite(handles.Variables.EarlyProgressionRate))
        fprintf('  ✗ 错误：EarlyProgressionRate 中存在 NaN 或 Inf\n');
    end
else
    fprintf('⚠ 警告：EarlyProgressionRate 未初始化\n');
end

if isfield(handles.Variables, 'Progression')
    fprintf('✓ Progression 系数存在 (%d 个值)\n', length(handles.Variables.Progression));
    fprintf('  Progression(5) = %.6f\n', handles.Variables.Progression(5));
else
    fprintf('✗ 错误：Progression 系数缺失\n');
end

% 测试 sigmoid 拟合
fprintf('\n--- Sigmoid 拟合测试 ---\n');
try
    index_age = 1:20;
    Benchmark_AdvAd_y    = 1/5 * handles.Variables.Benchmarks.AdvPolyp.Ov_y;
    Benchmark_AdvAd_perc = handles.Variables.Benchmarks.AdvPolyp.Ov_perc;
    
    i_sigmoid = @(A,u) A(1)./(1 + exp(-(u*A(2)-A(3))));
    fit_sigmoid = @(u,y,p0) fminsearch(@(p) sum((y - i_sigmoid(p,u)).^2), p0, ...
        optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',5000,'MaxFunEvals',10000,'Display','off'));
    
    CoeffsAdv = fit_sigmoid(Benchmark_AdvAd_y, Benchmark_AdvAd_perc, [8 1 9]);
    fprintf('✓ Sigmoid 拟合成功\n');
    fprintf('  系数: [%.4f, %.4f, %.4f]\n', CoeffsAdv(1), CoeffsAdv(2), CoeffsAdv(3));
    
    % 测试 EarlyProgressionRate 计算
    EarlyProgressionRate_test = 0.04*CoeffsAdv(1).*exp(-0.01*CoeffsAdv(2)*( index_age - CoeffsAdv(3) ).^2);
    
    if all(isfinite(EarlyProgressionRate_test))
        fprintf('✓ EarlyProgressionRate 计算无溢出\n');
        fprintf('  范围: [%.6f, %.6f]\n', min(EarlyProgressionRate_test), max(EarlyProgressionRate_test));
    else
        fprintf('✗ 错误：EarlyProgressionRate 计算产生 NaN 或 Inf\n');
    end
    
    % 测试学习率调整中的指数函数
    fprintf('\n--- 学习率指数函数测试 ---\n');
    test_deltas = [-5, -2, -1, 0, 1, 2, 5]; % 测试不同的 delta 值
    for delta = test_deltas
        exp_arg = -0.08 * delta;
        exp_arg_clipped = max(min(exp_arg, 10), -10);
        exp_result = exp(exp_arg_clipped);
        fprintf('  delta=%.1f: exp_arg=%.2f (clipped=%.2f) -> exp=%.4f\n', ...
            delta, exp_arg, exp_arg_clipped, exp_result);
    end
    
catch ME
    fprintf('✗ 错误：Sigmoid 拟合失败\n');
    fprintf('  消息: %s\n', ME.message);
end

% 运行一次快速模拟测试（使用很少的患者）
fprintf('\n--- 快速模拟测试 ---\n');
test_choice = input('是否运行快速模拟测试（1000 患者）？(y/n): ', 's');
if strcmpi(test_choice, 'y')
    fprintf('正在运行测试模拟...\n');
    
    % 备份设置
    OriginalPatients = handles.Variables.Number_patients;
    OriginalDispFlag = handles.Variables.DispFlag;
    OriginalResultsFlag = handles.Variables.ResultsFlag;
    
    % 设置为快速测试模式
    handles.Variables.Number_patients = 1000;
    handles.Variables.DispFlag = 0;
    handles.Variables.ResultsFlag = 0;
    
    try
        tic;
        [~, BM] = CalculateSub(handles);
        elapsed = toc;
        
        fprintf('✓ 模拟成功完成 (用时: %.2f 秒)\n', elapsed);
        fprintf('  Advanced Adenoma 输出点数: %d\n', length(BM.OutputValues.AdvAdenoma_Ov));
        
        % 检查 BM 输出
        if any(~isfinite(BM.OutputValues.AdvAdenoma_Ov))
            fprintf('  ✗ 警告：Advanced Adenoma 输出中存在 NaN 或 Inf\n');
        else
            fprintf('  ✓ Advanced Adenoma 输出数值正常\n');
        end
        
        if isfield(BM, 'Polyp_adv') && length(BM.Polyp_adv) >= 6
            fprintf('  Polyp_adv(5) = %.2f%%\n', BM.Polyp_adv(5));
            fprintf('  Polyp_adv(6) = %.2f%%\n', BM.Polyp_adv(6));
        end
        
    catch ME
        fprintf('✗ 模拟失败\n');
        fprintf('  错误: %s\n', ME.message);
    end
    
    % 恢复设置
    handles.Variables.Number_patients = OriginalPatients;
    handles.Variables.DispFlag = OriginalDispFlag;
    handles.Variables.ResultsFlag = OriginalResultsFlag;
end

fprintf('\n=== 诊断检查完成 ===\n');
fprintf('\n建议：\n');
fprintf('1. 如果所有检查都通过，可以尝试运行校准 Step 2\n');
fprintf('2. 建议首次迭代数设为 10-20，Nelder-Mead 迭代数设为 50\n');
fprintf('3. 使用 50,000 患者进行校准以平衡速度和精度\n');
fprintf('4. 监控 RMS 值：应该逐渐下降，正常范围 0.1-50\n');
fprintf('5. 如果 RMS 值超过 100，可能参数发散，需要停止并重新开始\n\n');

end
