
mat = [3,3;3,2;3,1;2,1;2,2;2,3;1,3;1,2;1,1];
% mat = [2,3;2,2;2,1;1,1;1,2;1,3];
% mat = [2,2;2,1;1,1;1,2];
for ii = 1:9
    key.animal_id = 5490;
    key.stitch_sess = 1;
    key.opt_file = ii;
    key.row_idx = mat(ii,1);
    key.column_idx = mat(ii,2);
    key.file_extension = ['00' num2str(ii)];
    key.surfz = 0;
    key.z = 300;
    key.notes = '';
    insert(info.StitchFile, key);
end