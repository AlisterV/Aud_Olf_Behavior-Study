function finaltask_thresh_comp(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)

[odor_thresh_array,sess_array] = finaltask_concthresh_bar(x_sound,x_sound_size,x_conc,x_conc_size,theFiles);

odor_only_thresh = odor_thresh_array(1,:);

odor_thresh_array = odor_thresh_array(2:end,:);

figure()
x_sound_hold = x_sound(2:end);
for h = 1:(x_sound_size - 1)
    curr_snd = x_sound_hold(h);
    for g = 1:length(odor_only_thresh)
        hold on
        subplot(2,3,h)
        scatter([1 2],[odor_only_thresh(g) odor_thresh_array(h,g)],'filled','HandleVisibility','off');
        hold on
        plot([1 2],[odor_only_thresh(g) odor_thresh_array(h,g)],'DisplayName',"sess "+string(sess_array(1,g)));
        hold on
        title("Odor and "+convertCharsToStrings(curr_snd)+"dB");
        hold on
        xticks([0 1 2 3])
        xticklabels({'','odor only','odor + sound',''})
        hold on
        legend('Location','best')
        hold on
    end
end
sgtitle('Odor Only threshold Compared to Odor and Specific Sound threshold')


[sound_thresh_array,sess_array] = finaltask_soundthresh_bar(x_sound,x_sound_size,x_conc,x_conc_size,theFiles);

sound_only_thresh = sound_thresh_array(1,:);

sound_thresh_array = sound_thresh_array(2:end,:);

figure()
x_conc_hold = x_conc(2:end);
for h = 1:(x_conc_size - 1)
    curr_conc = x_conc_hold(h);
    for g = 1:length(sound_only_thresh)
        hold on
        subplot(2,3,h)
        scatter([1 2],[sound_only_thresh(g) sound_thresh_array(h,g)],'filled','HandleVisibility','off');
        hold on
        plot([1 2],[sound_only_thresh(g) sound_thresh_array(h,g)],'DisplayName',"sess "+string(sess_array(1,g)));
        hold on
        title("Sound and "+convertCharsToStrings(curr_conc)+"Concentration");
        hold on
        xticks([0 1 2 3])
        xticklabels({'','sound only','sound + odor',''})
        hold on
        legend('Location','best')
        hold on
    end
end
sgtitle('Sound Only threshold Compared to Sound and Specific odor threshold')

end