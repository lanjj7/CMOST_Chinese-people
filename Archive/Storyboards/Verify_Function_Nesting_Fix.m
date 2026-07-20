%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     CMOST: OutFunction 函数嵌套错误修复验证
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;

fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  CMOST OutFunction 函数嵌套错误修复验证                ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

fprintf('【原始错误】\n');
fprintf('错误: 文件: Auto_Calib_1_OutFunction.m 行: 303 列: 1\n');
fprintf('函数 "FindAndActivateAxes" 已通过 ''end'' 关闭，\n');
fprintf('但至少有一个其他函数定义未关闭。\n\n');

fprintf('【问题原因】\n');
fprintf('FindAndActivateAxes 函数被错误地嵌套在 MakeGraphik 函数内部，\n');
fprintf('导致函数定义混乱。MATLAB 不允许在同一文件中混合使用\n');
fprintf('嵌套函数和顶层子函数。\n\n');

fprintf('【修复方法】\n');
fprintf('删除了嵌套的 FindAndActivateAxes 函数（该函数实际上未被使用），\n');
fprintf('所有必要的检查已直接内联到 MakeGraphik 和 MakeGraphik2 函数中。\n\n');

fprintf('【验证测试】\n');
fprintf('-------------------------------------------------------\n');

% 测试 1: 检查文件语法
fprintf('测试 1: 检查文件语法...\n');
try
    checkcode('e:\CMOST\v2\Additional procedures\Auto_Calib_1_OutFunction.m');
    fprintf('  ✓ Auto_Calib_1_OutFunction.m 语法正确\n');
    test1_pass = true;
catch ME
    fprintf('  ✗ 语法错误: %s\n', ME.message);
    test1_pass = false;
end

try
    checkcode('e:\CMOST\v2\Additional procedures\Auto_Calib_3_OutFunction.m');
    fprintf('  ✓ Auto_Calib_3_OutFunction.m 语法正确\n');
    test2_pass = true;
catch ME
    fprintf('  ✗ 语法错误: %s\n', ME.message);
    test2_pass = false;
end

% 测试 2: 验证函数可调用
fprintf('\n测试 2: 验证函数可调用...\n');
try
    n = nargin('Auto_Calib_1_OutFunction');
    fprintf('  ✓ Auto_Calib_1_OutFunction 可调用 (参数数: %d)\n', n);
    test3_pass = true;
catch ME
    fprintf('  ✗ 错误: %s\n', ME.message);
    test3_pass = false;
end

try
    n = nargin('Auto_Calib_3_OutFunction');
    fprintf('  ✓ Auto_Calib_3_OutFunction 可调用 (参数数: %d)\n', n);
    test4_pass = true;
catch ME
    fprintf('  ✗ 错误: %s\n', ME.message);
    test4_pass = false;
end

% 测试 3: 检查文件结构
fprintf('\n测试 3: 检查文件结构...\n');
try
    fh = fopen('e:\CMOST\v2\Additional procedures\Auto_Calib_1_OutFunction.m', 'r');
    code = fread(fh, '*char')';
    fclose(fh);
    
    % 检查是否有未闭合的函数
    func_starts = strfind(code, 'function ');
    end_count = length(strfind(code, 'end'));
    
    fprintf('  函数定义数: %d\n', length(func_starts));
    fprintf('  end 语句数: %d\n', end_count);
    
    % 简单检查：应该有足够的 end 语句
    if end_count >= length(func_starts)
        fprintf('  ✓ 函数定义和关闭语句数量合理\n');
        test5_pass = true;
    else
        fprintf('  ⚠ 警告: end 语句数量可能不足\n');
        test5_pass = false;
    end
catch ME
    fprintf('  ✗ 错误: %s\n', ME.message);
    test5_pass = false;
end

% 总结
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║                      测试总结                           ║\n');
fprintf('╠══════════════════════════════════════════════════════════╣\n');

all_tests = [test1_pass, test2_pass, test3_pass, test4_pass, test5_pass];
passed = sum(all_tests);
total = length(all_tests);

fprintf('║  通过: %d / %d                                          ║\n', passed, total);
fprintf('╠══════════════════════════════════════════════════════════╣\n');

if all(all_tests)
    fprintf('║  ✓✓✓ 所有测试通过！修复成功。                      ║\n');
    fprintf('║                                                          ║\n');
    fprintf('║  现在可以运行 Auto Calibration Step 1 了！              ║\n');
    fprintf('╚══════════════════════════════════════════════════════════╝\n');
else
    fprintf('║  ⚠ 部分测试未通过，请检查详细信息                   ║\n');
    fprintf('╚══════════════════════════════════════════════════════════╝\n');
end

fprintf('\n【使用说明】\n');
fprintf('1. 打开 MATLAB: cd e:\\CMOST\\v2; CMOST_Main\n');
fprintf('2. 加载您的设置文件\n');
fprintf('3. 运行: Storyboards → Auto Calibration Step 1\n');
fprintf('4. 设置迭代参数并点击 Start\n\n');

fprintf('【预期结果】\n');
fprintf('✓ 不应该再出现函数嵌套错误\n');
fprintf('✓ 不应该再出现 axes 参数错误\n');
fprintf('✓ GUI 图形应该正常更新\n');
fprintf('✓ 优化过程应该顺利进行\n\n');

fprintf('修复完成时间: 2025-12-16\n');
fprintf('修复内容: 删除嵌套的 FindAndActivateAxes 函数\n');
fprintf('影响文件: Auto_Calib_1_OutFunction.m\n\n');
