int: NL; % number of loaders
         % number of rails = NL for parts A-E
         % number of rails = (NL + 1) div 2 for part F
opt bool: partF; % are we solving stage F
set of int: LOADER = 1..NL;

enum CARGO; 
array[CARGO] of int: size; % size in 10000 tonne units

int: makespan; % maximum time considered.
set of int: TIME = 0..makespan;

enum SHIP; % set of ships
array[CARGO] of SHIP: ship; % which ship takes stockpile
array[SHIP] of TIME: arrival;  % when ship arrives

int: len; % length of pad
set of int: POS = 0..len; 

int: build_time; % time to build 1 unit (10000 tonnnes)
int: load_time; % time to load 1 unit
int: load_speed; % time for loader to move 1 unit

array[CARGO] of var POS: westx;
array[CARGO] of var POS: eastx;
array[CARGO] of var TIME: build;
array[CARGO] of var TIME: endbuild;
array[CARGO] of var TIME: load;
array[CARGO] of var TIME: finish;
array[CARGO] of var LOADER: which;

include "globals.mzn";
constraint forall(c in CARGO)(
    eastx[c] = westx[c] + size[c] 
    /\ endbuild[c] = build[c] + build_time * size[c] 
    /\ finish[c] = load[c] + load_time * size[c]
);
constraint forall(c in CARGO)(
    load[c] >= build[c] + size[c] * build_time
);
constraint diffn(
    westx, 
    build,
    size,
    [finish[c] - build[c] | c in CARGO]
);

constraint forall(l in LOADER)(
    disjunctive(
        [load[c] | c in CARGO], 
        [size[c] * load_time * (which[c]=l) | c in CARGO]
    )
);

output 
["westx  = array1d(CARGO,\(westx));\n"] ++
["eastx  = array1d(CARGO,\(eastx));\n"] ++
["build  = array1d(CARGO,\(build));\n"] ++
["endbuild  = array1d(CARGO,\(endbuild));\n"] ++
["load  = array1d(CARGO,\(load));\n"] ++
["finish  = array1d(CARGO,\(finish));\n"] ++
["which  = array1d(CARGO,\(which));\n"] 
;

% include "../viz/cargo_viz.mzn";
% output [cargo_viz(westx,eastx,build,endbuild,load,finish,which)];
