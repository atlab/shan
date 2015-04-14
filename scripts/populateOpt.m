animal = 'animal_id=5662';

populate(opt.Structure, animal);
populate(opt.StructureMask, animal);

populate(opt.Sync, animal);
populate(opt.SpotMap, animal);

opt.plots.SpotMapMerge(animal);