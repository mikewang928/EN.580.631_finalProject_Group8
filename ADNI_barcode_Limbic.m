T = readtable('ADNI_ICM_random200.xlsx');
%% 
% limbic system variable index 
limbic_variables = ["x_Amyg_R_", "x_Fimbria_R_", "x_Hippo_R_", "x_Mammillary_R_","x_Amyg_L_", "x_Fimbria_L_", "x_Hippo_L_", "x_Mammillary_L_"];
ind_limbic = find(contains(T.Properties.VariableNames,limbic_variables));
% data extraction
ind_normal = find(contains(T.x_Diagnosis_,string("NORMAL")));
ind_ADNI = find(contains(T.x_Diagnosis_,string("AD/MCI")));

Normal_table = T(ind_normal,:);
ADNI_table = T(ind_ADNI,:);
Normal_values = T{ind_normal,5:end};
ADNI_values = T{ind_ADNI,5:end};

%%
% calculating the z-score
[z_Normal,mu_Normal,sigma_Normal]  = zscore(Normal_values,0,1);
[z_ADNI,mu_ADNI,sigma_ADNI]  = zscore(ADNI_values,0,1);

%%
% filling the zscore to a new table 
Cell_normal =  num2cell(z_Normal);
Cell_ADNI = num2cell(z_ADNI);
%%
Normal_table(:,5:end)= Cell_normal;
ADNI_table(:,5:end) = Cell_ADNI;

%%
% plotting the heatmap of the z-scores
h_normal_y_label = Normal_table.x_Subject_ID_;
h_normal_x_label = Normal_table(1,ind_limbic).Properties.VariableNames;
h_normal_y_label = reshape(h_normal_y_label,[1 64]);


h_ADNI_y_label = ADNI_table.x_Subject_ID_;
h_ADNI_x_label = ADNI_table(1,ind_limbic).Properties.VariableNames;
h_ADNI_y_label = reshape(h_ADNI_y_label,[1 136]);
%%
hm_normal = heatmap(h_normal_x_label,h_normal_y_label,z_Normal(:,ind_limbic));
hm_normal.Title =  'Normal_patient_heatmap';
cmapeditor

%%
hm_ADNI= heatmap(h_ADNI_x_label,h_ADNI_y_label,z_ADNI(:,ind_limbic));
hm_ADNI.Title =  'ADNI_patient_heatmap'; 
cmapeditor


