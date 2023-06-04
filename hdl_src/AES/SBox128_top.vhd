library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SBox128_top is
  port (
    SYS_CLK, RST : in std_logic;
    PLAINTEXT_IN : in std_logic_vector (127 downto 0);
    KEY_IN : in std_logic_vector (127 downto 0);
    START : in std_logic;
    KEY_LOAD : in std_logic;
    DONE : out std_logic;
    BUSY : out std_logic;
    CIPHERTEXT_OUT : out std_logic_vector (127 downto 0));
end SBox128_top;

architecture Behavioral of SBox128_top is
  component SubBytes
    port (
      SubBytes_IN : in std_logic_vector(127 downto 0);
      SYS_CLK : in std_logic;
      RST : in std_logic;
      SubBytes_OUT : out std_logic_vector(127 downto 0)
    );
  end component;

  component AddRoundKey
    port (
      Data_IN : in std_logic_vector(127 downto 0);
      Key_IN : in std_logic_vector(127 downto 0);
      SYS_CLK : in std_logic;
      RST : in std_logic;
      Data_OUT : out std_logic_vector(127 downto 0)
    );
  end component;

  type state is (RESET_1, RESET_2, IDLE, PROCESSING);
  signal pr_state, nx_state : state;

  signal RST_BUF : std_logic := '0';
  signal BUSY_BUF : std_logic := '0';
  signal PLAINTEXT_BUFFER : std_logic_vector(127 downto 0) := (others => '0');
  signal OPN_COUNT : std_logic_vector(1 downto 0) := "00";

  signal KEY_BUF : std_logic_vector(127 downto 0) := (others => '0');
  signal SubBytes_IN_BUF : std_logic_vector(127 downto 0) := (others => '0');
  signal SubBytes_OUT_BUF : std_logic_vector(127 downto 0) := (others => '0');
  signal AddRoundKey_IN_BUF : std_logic_vector(127 downto 0) := (others => '0');
  signal AddRoundKey_OUT_BUF : std_logic_vector(127 downto 0) := (others => '0');

begin
  INST_SubBytes : SubBytes port map(
    SubBytes_IN => SubBytes_IN_BUF,
    SubBytes_OUT => SubBytes_OUT_BUF,
    SYS_CLK => SYS_CLK,
    RST => RST_BUF
  );
  INST_AddRoundKey : AddRoundKey port map(
    Data_IN => AddRoundKey_IN_BUF,
    Key_IN => KEY_BUF,
    Data_OUT => AddRoundKey_OUT_BUF,
    SYS_CLK => SYS_CLK,
    RST => RST_BUF
  );
  STATE_MACHINE_HEAD : process (SYS_CLK) ----State Machine Master Control
  begin
    if (SYS_CLK'event and SYS_CLK = '1') then
      if (RST = '1') then
        pr_state <= RESET_1;
      else
        pr_state <= nx_state;
      end if;
    end if;
  end process;

  STATE_MACHINE_BODY : process (START, OPN_COUNT, pr_state) ---State Machine State Definitions
  begin
    case pr_state is

      when RESET_1 => --Master Reset State
        RST_BUF <= '1';
        BUSY_BUF <= '0';
        nx_state <= RESET_2;

      when RESET_2 => --Extra Reset State to prevent reset glitching
        RST_BUF <= '1';
        BUSY_BUF <= '0';
        nx_state <= IDLE;

      when IDLE => --Waiting for Key Load or Data/Start assertion
        RST_BUF <= '0';
        BUSY_BUF <= '0';
        if (START = '1') then
          nx_state <= PROCESSING;
        else
          nx_state <= IDLE;
        end if;

      when PROCESSING => --Enable step/round counters
        RST_BUF <= '0';
        BUSY_BUF <= '1';
        if (OPN_COUNT = "11") then
          nx_state <= IDLE;
        else
          nx_state <= PROCESSING;
        end if;
    end case;
  end process;

  PLAINTEXT_INPUT_REGISTER : process (SYS_CLK)
  begin
    if (SYS_CLK'event and SYS_CLK = '1') then
      if (RST = '1') then
        PLAINTEXT_BUFFER <= (others => '0');
      elsif (START = '1' and PR_STATE = IDLE) then
        PLAINTEXT_BUFFER <= PLAINTEXT_IN;
      end if;
    end if;
  end process;

  MASTER_KEY_REGISTER : process (SYS_CLK)
  begin
    if (SYS_CLK'event and SYS_CLK = '1') then
      if (RST = '1') then
        KEY_BUF <= (others => '0') ;
      elsif (KEY_LOAD = '1' and BUSY_BUF = '0') then
        KEY_BUF <= KEY_IN;
      end if;
    end if;
  end process;

  CIPHER_TEXT_OUTPUT_REGISTER : process (SYS_CLK) --Output Latch for ciphertext
  begin
    if (SYS_CLK'event and SYS_CLK = '1') then
      if (PR_STATE = RESET_1 or PR_STATE = RESET_2) then
        CIPHERTEXT_OUT <= (others => '0');
      elsif (OPN_COUNT = "11") then
        CIPHERTEXT_OUT <= SubBytes_OUT_BUF;
      end if;
    end if;
  end process;

  OPERATIONS_COUNTER : process (SYS_CLK) ----Counts through each step and each round of cipher sequence, affects data path mux and state machine
  begin
    if (SYS_CLK'event and SYS_CLK = '1') then
      if (PR_STATE = RESET_1 or PR_STATE = RESET_2 or PR_STATE = IDLE) then
        OPN_COUNT <= "00"; --Step Counter Starts on 3 to correspond to AddRoundKey step at very start of cipher
      else
        OPN_COUNT <= OPN_COUNT + 1; ---Always increment when processing
      end if;
    end if;
  end process;

  ENCRYPT_DONE_SIGNAL_LATCH : process (SYS_CLK) ----Single Pulse Signal when cipher is complete and output data is valid
  begin
    if (SYS_CLK'event and SYS_CLK = '1') then
      if (OPN_COUNT = "11") then
        DONE <= '1';
      else
        DONE <= '0';
      end if;
    end if;
  end process;

  -----Set Core to Look BUSY during reset without actually asserting BUSY_BUF
  BUSY_OUTPUT_MUX : process (BUSY_BUF, pr_state)
  begin
    if (PR_STATE = RESET_1 or PR_STATE = RESET_2) then
      BUSY <= '1';
    else
      BUSY <= BUSY_BUF;
    end if;
  end process;
  AddRoundKey_IN_BUF <= PLAINTEXT_BUFFER;
  SubBytes_IN_BUF <= AddRoundKey_OUT_BUF;

end Behavioral;
