Οι παραμετροι μεγεθους στα αρχεια ειναι με μικρες τιμες για να βολευουν στην προσωμοιωση.

Σε περιπτωση που θελετε να τρεξετε τα αρχεια με τα μεγεθη που εγιναν τα bitstream (640x480 εικονα).
Πρεπει να πατε στα παρακατω αρχεια και να κανετε τις εξης αλλαγες:    

newframe.v -> "else if (hcount == 10'd9 && vcount == 10'd7) begin" αυτο να γινει "else if (hcount == 10'd639 && vcount == 10'd479) begin"

frame_timing.v -> Να μπουν σε σχολια τα πρωτα 5 και να βγουν απο σχολια τα κατω 5
parameter H_LIMIT = 20, V_LIMIT = 14;
parameter H_ACTIVE = 10, V_ACTIVE = 8;
parameter H_FP = 2, V_FP = 1; 
parameter H_SYNC = 5, V_SYNC = 3; 
parameter H_BP = 3, V_BP = 2; 

// parameter H_LIMIT = 800, V_LIMIT = 525;
// parameter H_ACTIVE = 640, V_ACTIVE = 480;
// parameter H_FP = 16, V_FP = 10; 
// parameter H_SYNC = 96, V_SYNC = 2; 
// parameter H_BP = 48, V_BP = 33;

στο pong.v -> Παλι τα πανω να μπυν σε σχολια και τα κατω να βγουν απο σχολια
    localparam SCREEN_WIDTH  = 10;
    localparam SCREEN_HEIGHT = 8;
    localparam PADDLE_W = 2;
    localparam PADDLE_H = 4;
    localparam PUCK_W   = 2;
    localparam PUCK_H   = 2;
    localparam PADDLE_X = 1;
    
    //(640x480)
//     localparam SCREEN_WIDTH  = 640;
//     localparam SCREEN_HEIGHT = 480;
//     localparam PADDLE_W = 10;
//     localparam PADDLE_H = 100;
//     localparam PUCK_W   = 32;
//     localparam PUCK_H   = 32;
//     localparam PADDLE_X = 10;

Επισης η ιδια αλλαγη στα σχολια και εδω
    always @(posedge clk or posedge reset) begin
        if (reset || new_game) begin
            paddle_y <= 4;
            puck_x   <= 5;
            puck_y   <= 4;
//            paddle_y <= 190;
//            puck_x   <= 304;
//            puck_y   <= 224;


Αμα καποιο αρχειο δεν υπαρχει σε καποιο part δεν υπαρχει προβλημα, απλως καντε τις αλλαγες σε αυτα που υπαρχουν