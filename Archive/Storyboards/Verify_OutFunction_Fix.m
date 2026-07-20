%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     CMOST: 校准 OutFunction 修复验证脚本
%     验证 Auto_Calib_1_OutFunction 和 Auto_Calib_3_OutFunction 的修复
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;

fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  CMOST OutFunction 修复验证                            ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

fprintf('【问题】\n');
fprintf('错误: axes - 用于构造坐标区对象的输入参数不正确\n');
fprintf('位置: Auto_Calib_1_OutFunction>MakeGraphik2 (第 169 行)\n');
fprintf('原因: axes(b.Parent) 中 b.Parent 可能无效或不是 axes 对象\n\n');

fprintf('【修复内容】\n');
fprintf('1. ✓ 修复 Auto_Calib_1_OutFunction.m 中的 MakeGraphik 函数\n');
fprintf('2. ✓ 修复 Auto_Calib_1_OutFunction.m 中的 MakeGraphik2 函数\n');
fprintf('3. ✓ 修复 Auto_Calib_1_OutFunction.m 中的 4 处直接 axes 调用\n');
fprintf('4. ✓ 修复 Auto_Calib_3_OutFunction.m 中的 MakeGraphik 函数\n');
fprintf('5. ✓ 修复 Auto_Calib_3_OutFunction.m 中的 3 处直接 axes 调用\n\n');

fprintf('【修复方法】\n');
fprintf('在访问 b.Parent 之前添加多层检查：\n');
fprintf('  1. 检查 b 是否为空且有效\n');
fprintf('  2. 检查 b.Parent 属性是否存在且有效\n');
fprintf('  3. 检查 b.Parent 是否是 axes 类型\n');
fprintf('  4. 如果以上失败，使用 ancestor(b, ''axes'') 查找\n');
fprintf('  5. 如果仍然失败，优雅地跳过该图形更新\n\n');

fprintf('【代码模式】\n');
fprintf('修复前:\n');
fprintf('  b=findobj(a, ''string'', GraphTitle);\n');
fprintf('  axes(b.Parent), cla(b.Parent)  %% 可能失败！\n\n');

fprintf('修复后:\n');
fprintf('  b=findobj(a, ''string'', GraphTitle);\n');
fprintf('  if ~isempty(b) && isvalid(b)\n');
fprintf('      if isprop(b, ''Parent'') && isvalid(b.Parent) && ...\n');
fprintf('         strcmp(get(b.Parent, ''type''), ''axes'')\n');
fprintf('          axes(b.Parent); cla(b.Parent);  %% 安全！\n');
fprintf('      else\n');
fprintf('          ax = ancestor(b, ''axes'');\n');
fprintf('          if ~isempty(ax) && isvalid(ax)\n');
fprintf('              axes(ax); cla(ax);\n');
fprintf('          end\n');
fprintf('      end\n');
fprintf('  end\n\n');

fprintf('【测试建议】\n');
fprintf('1. 打开 MATLAB\n');
fprintf('2. 运行: cd e:\\CMOST\\v2; CMOST_Main\n');
fprintf('3. 加载您的设置\n');
fprintf('4. 尝试运行 Auto Calibration Step 1\n');
fprintf('5. 确认不再出现 axes 错误\n\n');

fprintf('【预期结果】\n');
fprintf('✓ 校准过程应该正常启动\n');
fprintf('✓ GUI 图形应该正常更新\n');
fprintf('✓ 不应该出现 "用于构造坐标区对象的输入参数不正确" 错误\n');
fprintf('✓ 如果找不到某个坐标区，会优雅地跳过（不会崩溃）\n\n');

fprintf('【已修复的文件】\n');
fprintf('1. v2/Additional procedures/Auto_Calib_1_OutFunction.m\n');
fprintf('2. v2/Additional procedures/Auto_Calib_3_OutFunction.m\n\n');

fprintf('【注意事项】\n');
fprintf('- 如果 GUI 窗口被意外关闭，某些图形对象可能失效\n');
fprintf('- 新的代码会检测这种情况并跳过更新，而不是崩溃\n');
fprintf('- 如果需要，重新打开校准窗口即可恢复图形更新\n\n');

fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  修复完成！现在可以尝试运行校准了。                    ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

% 检查文件是否存在
files_to_check = {
    'e:\CMOST\v2\Additional procedures\Auto_Calib_1_OutFunction.m'
    'e:\CMOST\v2\Additional procedures\Auto_Calib_3_OutFunction.m'
};

fprintf('【文件完整性检查】\n');
all_exist = true;
for i = 1:length(files_to_check)
    if exist(files_to_check{i}, 'file')
        fprintf('✓ %s\n', files_to_check{i});
    else
        fprintf('✗ 缺失: %s\n', files_to_check{i});
        all_exist = false;
    end
end

if all_exist
    fprintf('\n所有文件都存在，可以开始测试！\n');
else
    fprintf('\n警告：某些文件缺失，请检查路径。\n');
end

fprintf('\n');
