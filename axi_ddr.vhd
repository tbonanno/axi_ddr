library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity axi_ddr is
  Port (
    DDR_addr            : inout std_logic_vector(14 downto 0);
    DDR_ba              : inout std_logic_vector( 2 downto 0);
    DDR_cas_n           : inout std_logic;
    DDR_ck_n            : inout std_logic;
    DDR_ck_p            : inout std_logic;
    DDR_cke             : inout std_logic;
    DDR_cs_n            : inout std_logic;
    DDR_dm              : inout std_logic_vector( 3 downto 0);
    DDR_dq              : inout std_logic_vector(31 downto 0);
    DDR_dqs_n           : inout std_logic_vector( 3 downto 0);
    DDR_dqs_p           : inout std_logic_vector( 3 downto 0);
    DDR_odt             : inout std_logic;
    DDR_ras_n           : inout std_logic;
    DDR_reset_n         : inout std_logic;
    DDR_we_n            : inout std_logic;
    FIXED_IO_ddr_vrn    : inout std_logic;
    FIXED_IO_ddr_vrp    : inout std_logic;
    FIXED_IO_mio        : inout std_logic_vector(53 downto 0);
    FIXED_IO_ps_clk     : inout std_logic;
    FIXED_IO_ps_porb    : inout std_logic;
    FIXED_IO_ps_srstb   : inout std_logic
  );
end axi_ddr;

architecture rtl of axi_ddr is

  signal FCLK_CLK0      : std_logic;
  signal aresetn        : std_logic;
  signal aresetn_vector : std_logic_vector(0 downto 0);

  signal araddr        : std_logic_vector(31 downto 0);
  signal arburst       : std_logic_vector( 1 downto 0);
  signal arcache       : std_logic_vector( 3 downto 0);
  signal arid          : std_logic_vector( 5 downto 0);
  signal arlen         : std_logic_vector( 7 downto 0);
  signal arlock        : std_logic_vector( 0 downto 0);
  signal arprot        : std_logic_vector( 2 downto 0);
  signal arqos         : std_logic_vector( 3 downto 0);
  signal arready       : std_logic;
  signal arregion      : std_logic_vector( 3 downto 0);
  signal arsize        : std_logic_vector( 2 downto 0);
  signal arvalid       : std_logic;
  signal awaddr        : std_logic_vector(31 downto 0);
  signal awburst       : std_logic_vector( 1 downto 0);
  signal awcache       : std_logic_vector( 3 downto 0);
  signal awid          : std_logic_vector( 5 downto 0);
  signal awlen         : std_logic_vector( 7 downto 0);
  signal awlock        : std_logic_vector( 0 downto 0);
  signal awprot        : std_logic_vector( 2 downto 0);
  signal awqos         : std_logic_vector( 3 downto 0);
  signal awready       : std_logic;
  signal awregion      : std_logic_vector( 3 downto 0);
  signal awsize        : std_logic_vector( 2 downto 0);
  signal awvalid       : std_logic;
  signal bid           : std_logic_vector( 5 downto 0);
  signal bready        : std_logic;
  signal bresp         : std_logic_vector( 1 downto 0);
  signal bvalid        : std_logic;
  signal rdata         : std_logic_vector(31 downto 0);
  signal rid           : std_logic_vector( 5 downto 0);
  signal rlast         : std_logic;
  signal rready        : std_logic;
  signal rresp         : std_logic_vector( 1 downto 0);
  signal rvalid        : std_logic;
  signal wdata         : std_logic_vector(31 downto 0);
  signal wlast         : std_logic;
  signal wready        : std_logic;
  signal wstrb         : std_logic_vector( 3 downto 0);
  signal wvalid        : std_logic;

  type burst_state is (IDLE, RUN);
  signal burst_cur_state, burst_nxt_state : burst_state;

  signal burst_go, burst_go_q   : std_logic;
  signal cb_count_q, cb_count_d : std_logic_vector(10 downto 0);
  signal cb_word_q, cb_word_d   : std_logic_vector(11 downto 0);

component design_1_wrapper
  port (
    ARESETN           : in    std_logic;
    AXI_araddr        : in    std_logic_vector(31 downto 0);
    AXI_arburst       : in    std_logic_vector( 1 downto 0);
    AXI_arcache       : in    std_logic_vector( 3 downto 0);
    AXI_arid          : in    std_logic_vector( 5 downto 0);
    AXI_arlen         : in    std_logic_vector( 7 downto 0);
    AXI_arlock        : in    std_logic_vector( 0 downto 0);
    AXI_arprot        : in    std_logic_vector( 2 downto 0);
    AXI_arqos         : in    std_logic_vector( 3 downto 0);
    AXI_arready       : out   std_logic;
    AXI_arregion      : in    std_logic_vector( 3 downto 0);
    AXI_arsize        : in    std_logic_vector( 2 downto 0);
    AXI_arvalid       : in    std_logic;
    AXI_awaddr        : in    std_logic_vector(31 downto 0);
    AXI_awburst       : in    std_logic_vector( 1 downto 0);
    AXI_awcache       : in    std_logic_vector( 3 downto 0);
    AXI_awid          : in    std_logic_vector( 5 downto 0);
    AXI_awlen         : in    std_logic_vector( 7 downto 0);
    AXI_awlock        : in    std_logic_vector( 0 downto 0);
    AXI_awprot        : in    std_logic_vector( 2 downto 0);
    AXI_awqos         : in    std_logic_vector( 3 downto 0);
    AXI_awready       : out   std_logic;
    AXI_awregion      : in    std_logic_vector( 3 downto 0);
    AXI_awsize        : in    std_logic_vector( 2 downto 0);
    AXI_awvalid       : in    std_logic;
    AXI_bid           : out   std_logic_vector( 5 downto 0);
    AXI_bready        : in    std_logic;
    AXI_bresp         : out   std_logic_vector( 1 downto 0);
    AXI_bvalid        : out   std_logic;
    AXI_rdata         : out   std_logic_vector(31 downto 0);
    AXI_rid           : out   std_logic_vector( 5 downto 0);
    AXI_rlast         : out   std_logic;
    AXI_rready        : in    std_logic;
    AXI_rresp         : out   std_logic_vector( 1 downto 0);
    AXI_rvalid        : out   std_logic;
    AXI_wdata         : in    std_logic_vector(31 downto 0);
    AXI_wlast         : in    std_logic;
    AXI_wready        : out   std_logic;
    AXI_wstrb         : in    std_logic_vector( 3 downto 0);
    AXI_wvalid        : in    std_logic;
    DDR_addr          : inout std_logic_vector(14 downto 0);
    DDR_ba            : inout std_logic_vector( 2 downto 0);
    DDR_cas_n         : inout std_logic;
    DDR_ck_n          : inout std_logic;
    DDR_ck_p          : inout std_logic;
    DDR_cke           : inout std_logic;
    DDR_cs_n          : inout std_logic;
    DDR_dm            : inout std_logic_vector( 3 downto 0);
    DDR_dq            : inout std_logic_vector(31 downto 0);
    DDR_dqs_n         : inout std_logic_vector( 3 downto 0);
    DDR_dqs_p         : inout std_logic_vector( 3 downto 0);
    DDR_odt           : inout std_logic;
    DDR_ras_n         : inout std_logic;
    DDR_reset_n       : inout std_logic;
    DDR_we_n          : inout std_logic;
    FCLK_CLK0         : out   std_logic;
    FIXED_IO_ddr_vrn  : inout std_logic;
    FIXED_IO_ddr_vrp  : inout std_logic;
    FIXED_IO_mio      : inout std_logic_vector(53 downto 0);
    FIXED_IO_ps_clk   : inout std_logic;
    FIXED_IO_ps_porb  : inout std_logic;
    FIXED_IO_ps_srstb : inout std_logic
  );
end component;

COMPONENT vio_top
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in2 : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    probe_in3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    probe_in4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_in6 : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    probe_in7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in8 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    probe_in9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_in10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    probe_out4 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    probe_out5 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out6 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    probe_out7 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    probe_out8 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    probe_out9 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out10 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_out11 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    probe_out12 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    probe_out13 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    probe_out14 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    probe_out15 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out16 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    probe_out17 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    probe_out18 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    probe_out19 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out20 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out21 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out22 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_out23 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    probe_out24 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out25 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    probe_out26 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out27 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

begin

process(FCLK_CLK0) begin
  if (aresetn = '0') then
    burst_cur_state <= IDLE;

    cb_count_q <= (others => '0');
    cb_word_q <= (others => '0');
  elsif rising_edge(FCLK_CLK0) then
    burst_cur_state <= burst_nxt_state;

    cb_count_q <= cb_count_d;
    cb_word_q <= cb_word_d;

    burst_go_q <= burst_go;
  end if;
end process;

process(all) begin
  burst_nxt_state <= burst_cur_state;

  cb_count_d <= cb_count_q;
  cb_word_d <= cb_word_q;

  wvalid <= '0';
  awvalid <= '0';

  case burst_cur_state is

    when IDLE =>
      if (burst_go = '1' and burst_go_q = '0') then
        burst_nxt_state <= RUN;
      end if;

    when RUN =>
      wvalid <= '1';
      if (cb_word_q(7 downto 0) = "00000000") then
        awvalid <= '1';
      end if;

      if (wready = '1') then
        if (cb_word_q = "111111111111") then

          if (cb_count_q = "11111001111") then
            burst_nxt_state <= IDLE;

            cb_count_d <= (others => '0');
          else
            cb_count_d <= std_logic_vector(unsigned(cb_count_q) + '1');
          end if;
        end if;

        cb_word_d <= std_logic_vector(unsigned(cb_word_q) + '1');
      end if;
    when others =>
      burst_nxt_state <= IDLE;

      cb_count_d <= (others => '0');
      cb_word_d <= (others => '0');
  end case;

  wdata <= "00000" & cb_count_q & "0000" & cb_word_q;
  awaddr <= std_logic_vector(unsigned("0000000" & cb_count_q & cb_word_q & "00") + X"0010_0000");

end process;

u_design_1_wrapper : design_1_wrapper
  port map (
    ARESETN           => aresetn,           -- in    std_logic;
    AXI_araddr        => araddr,            -- in    std_logic_vector(31 downto 0);
    AXI_arburst       => (others => '0'),           -- in    std_logic_vector( 1 downto 0);
    AXI_arcache       => (others => '0'),           -- in    std_logic_vector( 3 downto 0);
    AXI_arid          => (others => '0'),              -- in    std_logic_vector( 5 downto 0);
    AXI_arlen         => (others => '0'),             -- in    std_logic_vector( 7 downto 0);
    AXI_arlock        => (others => '0'),            -- in    std_logic_vector( 0 downto 0);
    AXI_arprot        => (others => '0'),            -- in    std_logic_vector( 2 downto 0);
    AXI_arqos         => (others => '0'),             -- in    std_logic_vector( 3 downto 0);
    AXI_arready       => open,           -- out   std_logic;
    AXI_arregion      => (others => '0'),          -- in    std_logic_vector( 3 downto 0);
    AXI_arsize        => (others => '0'),            -- in    std_logic_vector( 2 downto 0);
    AXI_arvalid       => arvalid,           -- in    std_logic;
    AXI_awaddr        => awaddr,            -- in    std_logic_vector(31 downto 0);
    AXI_awburst       => "01",           -- in    std_logic_vector( 1 downto 0);
    AXI_awcache       => (others => '0'),           -- in    std_logic_vector( 3 downto 0);
    AXI_awid          => (others => '0'),              -- in    std_logic_vector( 5 downto 0);
    AXI_awlen         => (others => '1'),             -- in    std_logic_vector( 7 downto 0);
    AXI_awlock        => (others => '0'),            -- in    std_logic_vector( 0 downto 0);
    AXI_awprot        => (others => '0'),            -- in    std_logic_vector( 2 downto 0);
    AXI_awqos         => (others => '0'),             -- in    std_logic_vector( 3 downto 0);
    AXI_awready       => open,           -- out   std_logic;
    AXI_awregion      => awregion,          -- in    std_logic_vector( 3 downto 0);
    AXI_awsize        => "010",            -- in    std_logic_vector( 2 downto 0);
    AXI_awvalid       => awvalid,           -- in    std_logic;
    AXI_bid           => open,               -- out   std_logic_vector( 5 downto 0);
    AXI_bready        => '1',            -- in    std_logic;
    AXI_bresp         => open,             -- out   std_logic_vector( 1 downto 0);
    AXI_bvalid        => open,            -- out   std_logic;
    AXI_rdata         => rdata,             -- out   std_logic_vector(31 downto 0);
    AXI_rid           => open,               -- out   std_logic_vector( 5 downto 0);
    AXI_rlast         => open,             -- out   std_logic;
    AXI_rready        => '1',            -- in    std_logic;
    AXI_rresp         => open,             -- out   std_logic_vector( 1 downto 0);
    AXI_rvalid        => open,            -- out   std_logic;
    AXI_wdata         => wdata,             -- in    std_logic_vector(31 downto 0);
    AXI_wlast         => '0',             -- in    std_logic;
    AXI_wready        => wready,            -- out   std_logic;
    AXI_wstrb         => (others => '1'),             -- in    std_logic_vector( 3 downto 0);
    AXI_wvalid        => wvalid,            -- in    std_logic;
    DDR_addr          => DDR_addr,          -- inout std_logic_vector(14 downto 0);
    DDR_ba            => DDR_ba,            -- inout std_logic_vector( 2 downto 0);
    DDR_cas_n         => DDR_cas_n,         -- inout std_logic;
    DDR_ck_n          => DDR_ck_n,          -- inout std_logic;
    DDR_ck_p          => DDR_ck_p,          -- inout std_logic;
    DDR_cke           => DDR_cke,           -- inout std_logic;
    DDR_cs_n          => DDR_cs_n,          -- inout std_logic;
    DDR_dm            => DDR_dm,            -- inout std_logic_vector( 3 downto 0);
    DDR_dq            => DDR_dq,            -- inout std_logic_vector(31 downto 0);
    DDR_dqs_n         => DDR_dqs_n,         -- inout std_logic_vector( 3 downto 0);
    DDR_dqs_p         => DDR_dqs_p,         -- inout std_logic_vector( 3 downto 0);
    DDR_odt           => DDR_odt,           -- inout std_logic;
    DDR_ras_n         => DDR_ras_n,         -- inout std_logic;
    DDR_reset_n       => DDR_reset_n,       -- inout std_logic;
    DDR_we_n          => DDR_we_n,          -- inout std_logic;
    FCLK_CLK0         => FCLK_CLK0,         -- out   std_logic;
    FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,  -- inout std_logic;
    FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,  -- inout std_logic;
    FIXED_IO_mio      => FIXED_IO_mio,      -- inout std_logic_vector(53 downto 0);
    FIXED_IO_ps_clk   => FIXED_IO_ps_clk,   -- inout std_logic;
    FIXED_IO_ps_porb  => FIXED_IO_ps_porb,  -- inout std_logic;
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb  -- inout std_logic_vector
  );


u_vio_top : vio_top
  PORT MAP (
    clk            => FCLK_CLK0,
    probe_in0(0)   => arready,
    probe_in1(0)   => awready,
    probe_in2      => bid,
    probe_in3      => bresp,
    probe_in4(0)   => bvalid,
    probe_in5      => rdata,
    probe_in6      => rid,
    probe_in7(0)   => rlast,
    probe_in8      => rresp,
    probe_in9(0)   => rvalid,
    probe_in10(0)  => wready,
    probe_out0     => araddr,
    probe_out1     => arburst,
    probe_out2     => arcache,
    probe_out3     => arid,
    probe_out4     => arlen,
    probe_out5     => arlock,
    probe_out6     => arprot,
    probe_out7     => arqos,
    probe_out8     => arsize,
    probe_out9(0)  => arvalid,
    probe_out10    => open,
    probe_out11    => open,
    probe_out12    => awcache,
    probe_out13    => awid,
    probe_out14    => open,
    probe_out15    => awlock,
    probe_out16    => awprot,
    probe_out17    => awqos,
    probe_out18    => open,
    probe_out19    => open,
    probe_out20    => open,
    probe_out21    => open,
    probe_out22    => open,
    probe_out23    => open,
    probe_out24    => open,
    probe_out25    => open,
    probe_out26(0) => burst_go,
    --probe_out26    => open,
    probe_out27(0)    => aresetn
  );

end rtl;
