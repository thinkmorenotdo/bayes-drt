% fit experimental files


data_path = '../../../data/experimental';

% LIB data
% lib_files = dir(strcat(data_path,'/','DRTtools_LIB_data*'));
% lib_suffixes = {'LIB_data','LIB_data_qtr'};
% lib_tau = logspace(-6,6,250);

% fit_files(lib_files,@DRT,'LIB_DRT_modality.csv',lib_tau,lib_suffixes)
% fit_files(lib_files,@jh_DRT_WithInductance,'LIB_DRT-Induc_modality.csv',lib_tau,lib_suffixes)

% TCO data
tco_files = dir(strcat(data_path,'/','PDAC_COM*'));
tco_suffixes = {'PDAC'};
tco_tau = logspace(-8,5,300);

% fit_files(tco_files,@DRT,'PDAC_DRT_modality.csv',tco_tau,tco_suffixes)
% fit_files(tco_files,@jh_DRT_TpDDT,'PDAC_DRT-TpDDT_modality.csv',tco_tau,tco_suffixes)
fit_files(tco_files,@jh_DRT_TpGer,'PDAC_DRT-TpGer_modality.csv',tco_tau,tco_suffixes)


function fit_files(files,fun,modality_file,tau,suffixes)
    functionHandle=functions(fun);
    if strcmp(functionHandle.function,'DRT')
        modalities = zeros(length(files),1);
        function_suffix = '_DRT';
    elseif strcmp(functionHandle.function,'jh_DRT_WithInductance')
        modalities = zeros(length(files),1);
        function_suffix = '_DRT-Induc';
    elseif strcmp(functionHandle.function,'jh_DRT_TpDDT')
        modalities = zeros(length(files),2);
        function_suffix = '_DRT-TpDDT';
    elseif strcmp(functionHandle.function,'jh_DRT_TpGer')
        modalities = zeros(length(files),2);
        function_suffix = '_DRT-TpGer';
%     elseif strcmp(functionHandle.function,'jh_DRT_TpDDT_BpDDT')
%         modalities = zeros(length(files),3);
%     else
%         modalities = zeros(length(files),1);
    end
    
%     t_plot = log(tau);
    
    for n = 1:length(files)
        file = files(n);
        suffix = suffixes{n};
        disp(file.name)
        [modality,betak,Rml,muml,wml,tl,Fl,Z_res] = jh_fit_exp_file(file.name,fun,true);
        modalities(n,:) = modality;
        % save output variables for later analysis
        save(strcat('results/vars_',suffix,function_suffix),...
            'modality','betak','Rml','muml','wml','tl','Fl');
        
        writetable(Z_res,strcat('results/Zout','_',suffix,function_suffix,'.csv'))
        
        %% get predicted distribution(s)
        % Because tl may be of different lengths for different
        % distributions, must save each distribution in its own file
        FlTemp=Fl{1}; %DRT
        g_res = array2table([tl{1}' FlTemp(2,:)' FlTemp(1,:)' FlTemp(3,:)'],... 
            'VariableNames',{'tau' 'gamma' 'gamma_lo' 'gamma_hi'});
        writetable(g_res,strcat('results/Gout','_',suffix,function_suffix,'.csv'))
        
        if strcmp(functionHandle.function,'jh_DRT_TpDDT') || strcmp(functionHandle.function,'jh_DRT_TpDDT_BpDDT') || strcmp(functionHandle.function,'jh_DRT_TpGer')
            Ftp=Fl{2}; %TP-DDT
            ftp_res = array2table([tl{2}' Ftp(2,:)' Ftp(1,:)' Ftp(3,:)'],... 
             'VariableNames',{'tau' 'ftp' 'ftp_lo' 'ftp_hi'});
            writetable(ftp_res,strcat('results/Ftp','_',suffix,function_suffix,'.csv'))
        end
%         if strcmp(functionHandle.function,'jh_DRT_TpDDT_BpDDT')
%             Fbp=Fl{3}; %BP-DDT
%             fbp_res = array2table([tl{3}' Fbp(2,:)' Fbp(1,:)' Fbp(3,:)'],... 
%              'VariableNames',{'tau' 'fbp' 'fbp_lo' 'fbp_hi'});
%             writetable(fbp_res,strcat('results/Fbp_',suffix,function_suffix))
%         end
        
          % Evaluate each distribution at user-specified mesh points
          % this code does not produce credible intervals correctly.
          % Reverted to using Fl output
%         % 1st distribution (DRT)
%         f1_modality = modality(1);
%         [t_out,F_lo] = evaluateDistribution(Rml(1:f1_modality,1),muml(1:f1_modality,1),wml(1:f1_modality,1),{'series'},t_plot);
%         [t_out,F_mid] = evaluateDistribution(Rml(1:f1_modality,2),muml(1:f1_modality,2),wml(1:f1_modality,2),{'series'},t_plot);
%         [t_out,F_hi] = evaluateDistribution(Rml(1:f1_modality,3),muml(1:f1_modality,3),wml(1:f1_modality,3),{'series'},t_plot);
%             
%         g_res = array2table([t_plot' F_mid' F_lo' F_hi'],... 
%             'VariableNames',{'tau' 'gamma' 'gamma_lo' 'gamma_hi'});
%         writetable(g_res,strcat('results/Gout','_',suffix,function_suffix,'.csv'))
%         
%         if strcmp(functionHandle.function,'jh_DRT_TpDDT') || strcmp(functionHandle.function,'jh_DRT_TpDDT_BpDDT') || strcmp(functionHandle.function,'jh_DRT_TpGer')
%             f2_modality = modality(2);
%             row_start = f1_modality + 1;
%             row_end = f1_modality + f2_modality;
%             [t_out,F_lo] = evaluateDistribution(Rml(row_start:row_end,1),muml(row_start:row_end,1),wml(row_start:row_end,1),{'parallel'},t_plot);
%             [t_out,F_mid] = evaluateDistribution(Rml(row_start:row_end,2),muml(row_start:row_end,2),wml(row_start:row_end,2),{'parallel'},t_plot);
%             [t_out,F_hi] = evaluateDistribution(Rml(row_start:row_end,3),muml(row_start:row_end,3),wml(row_start:row_end,3),{'parallel'},t_plot);
%             ftp_res = array2table([t_plot' F_mid' F_lo' F_hi'],... 
%              'VariableNames',{'tau' 'ftp' 'ftp_lo' 'ftp_hi'});
%             writetable(ftp_res,strcat('results/Ftp','_',suffix,function_suffix,'.csv'))
%         end
% %         if strcmp(functionHandle.function,'jh_DRT_TpDDT_BpDDT')
% %             Fbp=Fl{3}; %BP-DDT
% %             fbp_res = array2table([tl{3}' Fbp(2,:)' Fbp(1,:)' Fbp(3,:)'],... 
% %              'VariableNames',{'tau' 'fbp' 'fbp_lo' 'fbp_hi'});
% %             writetable(fbp_res,strcat('results/Fbp','_',suffix))
% %         end
    end
    
    if strcmp(functionHandle.function,'jh_DRT_TpDDT') || strcmp(functionHandle.function,'jh_DRT_TpGer')
        file_mod = table({files.name}', modalities(:,1), modalities(:,2),...
        'VariableNames',{'file' 'gamma_modality' 'ftp_modality'});
    elseif strcmp(functionHandle.function,'jh_DRT_TpDDT_BpDDT')
        file_mod = table({files.name}', modalities(:,1), modalities(:,2), modalities(:,3),...
        'VariableNames',{'file' 'gamma_modality' 'ftp_modality' 'fbp_modality'});
    else
        file_mod = table({files.name}', modalities,...
            'VariableNames',{'file' 'modality'});
    end
    writetable(file_mod,strcat('results/',modality_file));
end