// settings

(
/*
* Tempo in bpm.
* num
*/
~tempo = 60;

/*
* Enable recording.
* boolean
*/
~record_enable = false;

/*
* Recording name.
* string
*/
~record_name = "scd";

/*
* Total number of sections to create.
* int
*/
~total_section_count = rrand(5,7);

/*
* The length of each section.
* array, [minimum, maximum]
*/
~section_length = [60, 120];

~motif_create_chance = 0.1;

~motif_rentention_chance = 0.5;

~max_motives = 3;

~root_range = rrand(45, 50);
)