/// The virtual lab is available to every board from Class 7 through Class 12.
bool labAvailableForSelection(Iterable<int> selectedClasses) =>
    selectedClasses.any((classNo) => classNo >= 7 && classNo <= 12);
