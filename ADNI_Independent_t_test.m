T = readtable('ADNI_ICM_random200.xlsx');
%% 
% limbic system variable index 
limbic_variables = ["x_Amyg_R_", "x_Fimbria_R_", "x_Hippo_R_", "x_Mammillary_R_","x_Amyg_L_", "x_Fimbria_L_", "x_Hippo_L_", "x_Mammillary_L_"];
ind_limbic = find(contains(T.Properties.VariableNames,limbic_variables));
% data extraction
ind_normal = find(contains(T.x_Diagnosis_,string("NORMAL")));
ind_ADNI = find(contains(T.x_Diagnosis_,string("AD/MCI")));
Normal_table = T(ind_normal,limbic_variables);
ADNI_table = T(ind_ADNI,limbic_variables);
Normal_values = T{ind_normal,limbic_variables};
ADNI_values = T{ind_ADNI,limbic_variables};

%%
% applying independent t test 
size_limbic_variables = size(limbic_variables);
for i = 1:size_limbic_variables(2)
    h = ttest2(Normal_values(:,ind_limbic(i)),ADNI_values(:,ind_limbic(i)));
    if h == 1
        disp("+" + limbic_variables(i)+" volumn has statistic different between healthy and ADNI subjects")
    elseif h ==0
        disp("-" + limbic_variables(i)+" volumn does not have statistic different between healthy and ADNI subjects")
    end 
end 



