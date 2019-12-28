--------------------------------------------------------------------------------
--
--   FileName:         i2s_playback.vhd
--   Dependencies:     i2s_transceiver.vhd, clk_wiz_0 (PLL)
--   Design Software:  Vivado v2017.2
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 04/19/2019 Scott Larson
--     Initial Public Release
-- 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY i2s_playback IS
    GENERIC(
        d_width     :  INTEGER := 24);                    --data width
    PORT(
        clock       :  IN  STD_LOGIC;                     --system clock (100 MHz on Basys board)
        reset_n     :  IN  STD_LOGIC;                     --active low asynchronous reset
        mclk        :  OUT STD_LOGIC_VECTOR(1 DOWNTO 0);  --master clock
        sclk        :  OUT STD_LOGIC_VECTOR(1 DOWNTO 0);  --serial clock (or bit clock)
        ws          :  OUT STD_LOGIC_VECTOR(1 DOWNTO 0);  --word select (or left-right clock)
        sd_rx       :  IN  STD_LOGIC;                     --serial data in
        sd_tx       :  OUT STD_LOGIC);                    --serial data out
END i2s_playback;

ARCHITECTURE logic OF i2s_playback IS

    SIGNAL master_clk   :  STD_LOGIC;                             --internal master clock signal
    SIGNAL serial_clk   :  STD_LOGIC := '0';                      --internal serial clock signal
    SIGNAL word_select  :  STD_LOGIC := '0';                      --internal word select signal
    SIGNAL l_data_rx    :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data received from I2S Transceiver component
    SIGNAL r_data_rx    :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --right channel data received from I2S Transceiver component
    SIGNAL l_data_tx    :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data to transmit using I2S Transceiver component
    SIGNAL r_data_tx    :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --right channel data to transmit using I2S Transceiver component
 
    --declare PLL to create 11.29 MHz master clock from 100 MHz system clock
    COMPONENT clk_wiz_0
        PORT(
            clk_in1     :  IN STD_LOGIC  := '0';
            clk_out1    :  OUT STD_LOGIC);
        END COMPONENT;

    --declare I2S Transceiver component
    COMPONENT i2s_transceiver IS
        GENERIC(
            mclk_sclk_ratio :  INTEGER := 4;    --number of mclk periods per sclk period
            sclk_ws_ratio   :  INTEGER := 64;   --number of sclk periods per word select period
            d_width         :  INTEGER := 24);  --data width
        PORT(
            reset_n     :  IN   STD_LOGIC;                              --asynchronous active low reset
            mclk        :  IN   STD_LOGIC;                              --master clock
            sclk        :  OUT  STD_LOGIC;                              --serial clock (or bit clock)
            ws          :  OUT  STD_LOGIC;                              --word select (or left-right clock)
            sd_tx       :  OUT  STD_LOGIC;                              --serial data transmit
            sd_rx       :  IN   STD_LOGIC;                              --serial data receive
            l_data_tx   :  IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);   --left channel data to transmit
            r_data_tx   :  IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);   --right channel data to transmit
            l_data_rx   :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);   --left channel data received
            r_data_rx   :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0));  --right channel data received
    END COMPONENT;
    
BEGIN

    --instantiate PLL to create master clock
    i2s_clock: clk_wiz_0 
    PORT MAP(clk_in1 => clock, clk_out1 => master_clk);
  
    --instantiate I2S Transceiver component
    i2s_transceiver_0: i2s_transceiver
    GENERIC MAP(mclk_sclk_ratio => 4, sclk_ws_ratio => 64, d_width => 24)
    PORT MAP(reset_n => reset_n, mclk => master_clk, sclk => serial_clk, ws => word_select, sd_tx => sd_tx, sd_rx => sd_rx,
             l_data_tx => l_data_tx, r_data_tx => r_data_tx, l_data_rx => l_data_rx, r_data_rx => r_data_rx);
  
    mclk(0) <= master_clk;  --output master clock to ADC
    mclk(1) <= master_clk;  --output master clock to DAC
    sclk(0) <= serial_clk;  --output serial clock (from I2S Transceiver) to ADC
    sclk(1) <= serial_clk;  --output serial clock (from I2S Transceiver) to DAC
    ws(0) <= word_select;   --output word select (from I2S Transceiver) to ADC
    ws(1) <= word_select;   --output word select (from I2S Transceiver) to DAC

    r_data_tx <= r_data_rx;  --assign right channel received data to transmit (to playback out received data)
    l_data_tx <= l_data_rx;  --assign left channel received data to transmit (to playback out received data)

END logic;
