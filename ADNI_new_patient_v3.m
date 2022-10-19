%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                               extracting data from text file                                       % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define data path
new_patient_path_corrected = 'Result/output/MNI_286Labels_corrected_stats.txt';
new_patient_path_MNI = 'Result/output/MNI_286Labels_MNI_stats.txt';
T = readtable('ADNI_ICM_random200.xlsx');
%%
% define keyword arrays
limbic_variables_txt = ["Amyg_R", "Fimbria_R", "Hippo_R", "Mammillary_R","Amyg_L", "Fimbria_L", "Hippo_L", "Mammillary_L"];
new_patient_corrected_volume_array = [];
new_patient_MNI_volume_array = [];

% extracting the data array [corrected] 
size_limbic_variables  = size(limbic_variables_txt);
for i = 1:size_limbic_variables(2)
    volume_value = findTargetVolume(new_patient_path_corrected, limbic_variables_txt(i));
    new_patient_corrected_volume_array(end+1) = volume_value;
end 

% extracting the data array [MNI] 
size_limbic_variables  = size(limbic_variables_txt);
for i = 1:size_limbic_variables(2)
    volume_value = findTargetVolume(new_patient_path_MNI, limbic_variables_txt(i));
    new_patient_MNI_volume_array(end+1) = volume_value;
end 


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   calculating the z-score                                             % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
T_values = cat(1,Normal_values,ADNI_values);

%%
% calculating the z-score
[z_Normal,mu_Normal,sigma_Normal]  = zscore(Normal_values,0,1);
z_T_withRespect2Nrormal = findZScore(T_values,mu_Normal,sigma_Normal);

% calulating the z-score of the new patient for each normal and ADNI [CORRECTED]
z_new_patient_withRespect2Nrormal = findZScore(new_patient_corrected_volume_array, mu_Normal, sigma_Normal);
z_T_withRespect2Nrormal(end+1,:) = z_new_patient_withRespect2Nrormal;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   heat map plotting[Corrected]                                   % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constructing the x and y labels for the heat map
h_y_label_normal = T(ind_normal,:).x_Subject_ID_;
h_y_label_ADNI = T(ind_ADNI,:).x_Subject_ID_;
h_y_label = cat(1,h_y_label_normal,h_y_label_ADNI);
h_y_label(end +1) = {"new patient"};
h_x_label = Normal_table.Properties.VariableNames;

%%
hm_normal = heatmap(h_x_label,h_y_label,z_T_withRespect2Nrormal);
hm_normal.Title =  'new patient heatmap withRespectTo Normal dataset [CORRECTED]';
cmapeditor

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                              svm classfication with volume                                       % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constructing the training dataset 
train_all = cat(1,Normal_values,ADNI_values);
label_normal = zeros(size(ind_normal)); % zeros is normal 
label_ADNI = ones(size(ind_ADNI));
label_all = cat(1,label_normal,label_ADNI);

%%
% trainning the svm model 
SVMModel = fitcsvm(train_all,label_all);

%%
prediction_corrected_svm = SVMModel.predict(new_patient_corrected_volume_array);
if prediction_corrected_svm == 0
    disp("-[SVM] the new patient is **NORMAL** based on the corrected segmented volume data")
elseif prediction_corrected_svm == 1
    disp("+[SVM] the new patient **HAS ADNI** based on the corrected segmented volume data")
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                              svm classfication with z-score                                       % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constructing the training dataset 
train_all_z = z_T_withRespect2Nrormal(1:end-1,:);

%%
% trainning the svm model 
SVMModel_z = fitcsvm(train_all_z,label_all);

%%
prediction_corrected_z_svm = SVMModel_z.predict(z_new_patient_withRespect2Nrormal);
if prediction_corrected_z_svm == 0
    disp("-[SVM] the new patient is **NORMAL** based on the corrected z score with respect to Normal mean and variance")
elseif prediction_corrected_z_svm == 1
    disp("+[SVM] the new patient **HAS ADNI** based on the corrected z score with respect to Normal mean and variance")
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                         logistic regression with volume                                          % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogisticRegModel_z = fitclinear(train_all,label_all,"Learner","logistic","Lambda",10.^(-(10:-2:2)));
prediction_corrected_lr = LogisticRegModel_z.predict(new_patient_corrected_volume_array);
if prediction_corrected_lr == 0
    disp("-[LR] the new patient is **NORMAL** based on the corrected segmented volume")
elseif prediction_corrected_lr== 1
    disp("+[LR] the new patient **HAS ADNI** based on the corrected segmented volume")
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          logistic regression n with z-score                                      % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogisticRegModel_z = fitclinear(train_all_z,label_all,"Learner","logistic","Lambda",10.^(-(10:-2:2)));
prediction_corrected_z_lr = LogisticRegModel_z.predict(z_new_patient_withRespect2Nrormal);
if prediction_corrected_z_lr == 0
    disp("-[LR] the new patient is **NORMAL** based on the corrected z score with respect to Normal mean and variance")
elseif prediction_corrected_z_lr == 1
    disp("+[LR] the new patient **HAS ADNI** based on the corrected z score with respect to Normal mean and variance")
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                         helper function                                                  % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find target volume function 
function volume_value = findTargetVolume(file_path, target_keyword)
    fid = fopen(file_path);
    tline = fgetl(fid);
    lineCounter = 1;
    while ischar(tline)
        if contains(tline, target_keyword, 'IgnoreCase', true)
%             disp(tline)
            target_line = split(tline);
            volume_value = str2num(target_line{3});
            break;
        end
        % Read next line
        tline = fgetl(fid);
        lineCounter = lineCounter + 1;
    end
    fclose(fid);
end


% find z_socre function
function z_score = findZScore(test_array, mu, sigma)
    demean_test_array = test_array - mu;
    z_score = demean_test_array./sigma;
end 
