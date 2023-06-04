library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity SBox128_top_tb is
end SBox128_top_tb;

architecture behavioral of SBox128_top_tb is

  -- Component Declaration for the Unit Under Test (UUT)

  component SBox128_top
    port (
      SYS_CLK : in std_logic;
      RST : in std_logic;
      PLAINTEXT_IN : in std_logic_vector(127 downto 0);
      KEY_IN : in std_logic_vector(127 downto 0);
      START : in std_logic;
      KEY_LOAD : in std_logic;
      DONE : out std_logic;
      BUSY : out std_logic;
      CIPHERTEXT_OUT : out std_logic_vector(127 downto 0)
    );
  end component;
  --Inputs
  signal SYS_CLK : std_logic := '0';
  signal RST : std_logic := '0';
  signal PLAINTEXT_IN : std_logic_vector(127 downto 0) := (others => '0');
  signal KEY_IN : std_logic_vector(127 downto 0) := (others => '0');
  signal START : std_logic := '0';
  signal KEY_LOAD : std_logic := '0';

  --Outputs
  signal DONE : std_logic;
  signal BUSY : std_logic;
  signal CIPHERTEXT_OUT : std_logic_vector(127 downto 0);

  -- Clock period definitions
  constant SYS_CLK_period : time := 8 ns;

  signal CORRECT_OUTPUT : std_logic_vector(127 downto 0) := (others => '0');

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : SBox128_top port map(
    SYS_CLK => SYS_CLK,
    RST => RST,
    PLAINTEXT_IN => PLAINTEXT_IN,
    KEY_IN => KEY_IN,
    START => START,
    KEY_LOAD => KEY_LOAD,
    DONE => DONE,
    BUSY => BUSY,
    CIPHERTEXT_OUT => CIPHERTEXT_OUT
  );

  -- Clock process definitions
  SYS_CLK_process : process
  begin
    SYS_CLK <= '0';
    wait for SYS_CLK_period/2;
    SYS_CLK <= '1';
    wait for SYS_CLK_period/2;
  end process;
  -- Stimulus process
  stim_proc : process
  begin
    -- TEST 1	
    wait for SYS_CLK_period * 10;
    KEY_IN <= X"2b7e151628aed2a6abf7158809cf4f3c";
    KEY_LOAD <= '1';
    wait for SYS_CLK_period;
    KEY_LOAD <= '0';
    PLAINTEXT_IN <= X"3243f6a8885a308d313198a2e0370734";
    CORRECT_OUTPUT <= X"d42711aee0bf98f1b8b45de51e415230";
    START <= '1';
    wait for SYS_CLK_period;
    START <= '0';
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 1 FAILED"
      severity error;

    wait for SYS_CLK_period * 5;
    -- TEST 2 	
    KEY_IN <= X"F00102030405060708090A0B0C0D0E0F";
    KEY_LOAD <= '1';
    wait for SYS_CLK_period;
    KEY_LOAD <= '0';
    PLAINTEXT_IN <= X"F0112233445566778899AABBCCDDEEFF";
    CORRECT_OUTPUT <= X"63cab7040953d051cd60e0e7ba70e18c";
    START <= '1';
    wait for SYS_CLK_period;
    START <= '0';
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 2 FAILED"
      severity error;

    wait for SYS_CLK_period * 5;
    -- TEST 3 
    KEY_IN <= X"f0000000000000000000000000000000";
    KEY_LOAD <= '1';
    wait for SYS_CLK_period;
    KEY_LOAD <= '0';
    PLAINTEXT_IN <= X"f34481ec3cc627bacd5dc3fb08f273e6";
    CORRECT_OUTPUT <= X"7b1b0cceebb4ccf4bd4c2e0f30898f8e";
    START <= '1';
    wait for SYS_CLK_period;
    START <= '0';
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 3 FAILED"
      severity error;

    wait for SYS_CLK_period * 5;
    -- TEST 4	
    KEY_IN <= X"10a58869d74be5a374cf867cfb473859";
    KEY_LOAD <= '1';
    wait for SYS_CLK_period;
    KEY_LOAD <= '0';
    PLAINTEXT_IN <= X"f0000000000000000000000000000000";
    CORRECT_OUTPUT <= X"e106c4f90eb3d90a928a44100fa007cb";
    START <= '1';
    wait for SYS_CLK_period;
    START <= '0';
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 4 FAILED"
      severity error;

    wait for SYS_CLK_period * 5;
    -- TEST 5
    KEY_IN <= X"f0000000000000000000000000000000";
    KEY_LOAD <= '1';
    wait for SYS_CLK_period;
    KEY_LOAD <= '0';
    PLAINTEXT_IN <= X"c0000000000000000000000000000000";
    CORRECT_OUTPUT <= X"04636363636363636363636363636363";
    START <= '1';
    wait for SYS_CLK_period;
    START <= '0';
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 5 FAILED"
      severity error;

    wait for SYS_CLK_period * 5;
    -- TEST 6
    KEY_IN <= X"00000000000000000000000000000000";
    KEY_LOAD <= '1';
    wait for SYS_CLK_period;
    KEY_LOAD <= '0';
    PLAINTEXT_IN <= X"00000000000000000000000000000000";
    CORRECT_OUTPUT <= X"63636363636363636363636363636363";
    START <= '1';
    wait for SYS_CLK_period; ---Examples of Continuous Loading
    START <= '0';
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 6 FAILED"
      severity error;

    wait for SYS_CLK_period * 5;
    -- TEST 7
    KEY_IN <= X"E8E9EAEBEDEEEFF0F2F3F4F5F7F8F9FA";
    KEY_LOAD <= '1';
    PLAINTEXT_IN <= X"114BAF2278A69D331D5180103643E99A";
    START <= '1';
    wait for SYS_CLK_period * 10;
    CORRECT_OUTPUT <= X"993a6edd2a52402edf3a92d978eacad0";
    wait until DONE = '1';
    assert CIPHERTEXT_OUT = CORRECT_OUTPUT
    report "TEST 7 FAILED"
      severity error;

    wait;

  end process;

end;