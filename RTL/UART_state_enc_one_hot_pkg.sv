
/* ----------------------------------------------------------------------------------------------- //
Project Title: Digital Design of UART 
By: Marwan Eid
File Description: UART Rx/Tx One-Hot State Encoding Package
Last Updated: 13/09/2024
Email: eid.marwan.work@gmail.com
// ----------------------------------------------------------------------------------------------- */

package state_enc_one_hot_pkg;

    // state enumeration (one-hot encoding)
    typedef enum logic [5:0] {
        PRE_FIRST_IDLE = 6'b000001,
        IDLE           = 6'b000010,
        START          = 6'b000100,
        DATA           = 6'b001000,
        PARITY         = 6'b010000,
        STOP           = 6'b100000
    } state_e;

endpackage: state_enc_one_hot_pkg
