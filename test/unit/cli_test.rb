require 'test_helper'

module NewsScraper
  class CLITest < Minitest::Test
    def test_log
      log_default_color = capture_subprocess_io do
        CLI.log("message")
      end
      assert_equal "\e[36m┃\e[0m message\n", log_default_color.first

      log_color = capture_subprocess_io do
        CLI.log("message", color: "\x1b[35m")
      end
      assert_equal "\e[35m┃\e[0m message\n", log_color.first
    end

    def test_log_lines
      log_lings_default_color = capture_subprocess_io do
        CLI.log_lines("message\nmessage2")
      end
      assert_equal "\e[36m┃\e[0m message\n\e[36m┃\e[0m message2\n", log_lings_default_color.first

      log_lines_color = capture_subprocess_io do
        CLI.log_lines("message\nmessage2", color: "\x1b[35m")
      end
      assert_equal "\e[35m┃\e[0m message\n\e[35m┃\e[0m message2\n", log_lines_color.first
    end

    def test_confirm
      $stdin.expects(:gets).returns('y')
      true_confirm = capture_subprocess_io do
        assert CLI.confirm('test')
      end
      assert_equal "\e[36m┃\e[0m test (y/n) ", true_confirm.first

      $stdin.expects(:gets).returns('f')
      false_confirm = capture_subprocess_io do
        refute CLI.confirm('test2')
      end
      assert_equal "\e[36m┃\e[0m test2 (y/n) ", false_confirm.first
    end

    def test_get_input
      Readline.expects(:readline).returns('banana')

      io = capture_subprocess_io do
        assert_equal 'banana', CLI.get_input('test')
      end
      assert_equal "\e[36m┃\e[0m test\n\e[0m", io.first
    end

    def test_get_input_interrupts
      Readline.expects(:readline).raises(Interrupt)

      io = capture_subprocess_io do
        assert_nil CLI.get_input('test')
      end
      assert_equal "\e[36m┃\e[0m test\n\e[0m", io.first
    end

    def test_prompt_with_options
      Readline.expects(:readline).times(2).returns('banana', '1')

      io = capture_subprocess_io do
        assert_equal 'a', CLI.prompt_with_options('test', %w(a b))
      end
      assert_equal [
        "\e[36m┃\e[0m test",
        "\e[36m┃\e[0m Your options are:",
        "\e[36m┃\e[0m 1) a",
        "\e[36m┃\e[0m 2) b",
        "\e[36m┃\e[0m Choose a number between 1 and 2",
        "\e[0m"
      ].join("\n"), io.first
    end

    def test_prompt_with_options_interrupts
      Readline.expects(:readline).times(2).raises(Interrupt).returns('1')

      io = capture_subprocess_io do
        assert_equal 'a', CLI.prompt_with_options('test', %w(a b))
      end
      assert_equal [
        "\e[36m┃\e[0m test",
        "\e[36m┃\e[0m Your options are:",
        "\e[36m┃\e[0m 1) a",
        "\e[36m┃\e[0m 2) b",
        "\e[36m┃\e[0m Choose a number between 1 and 2",
        "\e[0m"
      ].join("\n"), io.first
    end

    # rubocop:disable Metrics/LineLength
    def test_put_header
      IO.stubs(:console).returns(nil)

      header_default_color = capture_subprocess_io do
        CLI.put_header('test')
      end
      assert_equal "\e[36m┏━━ test\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m\n", header_default_color.first

      header_color = capture_subprocess_io do
        CLI.put_header('test', color: "\x1b[35m")
      end
      assert_equal "\e[35m┏━━ test\e[35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m\n", header_color.first

      long_header_text = capture_subprocess_io do
        CLI.put_header('test' * 80, color: "\x1b[35m")
      end
      assert_equal "\e[35m┏━━ testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttes\e[35m\e[0m\n", long_header_text.first
    end

    def test_put_footer
      IO.stubs(:console).returns(nil)

      footer_default_color = capture_subprocess_io do
        CLI.put_footer
      end
      assert_equal "\e[36m┗\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m\n", footer_default_color.first

      footer_color = capture_subprocess_io do
        CLI.put_footer(color: "\x1b[35m")
      end
      assert_equal "\e[35m┗\e[35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m\n", footer_color.first
    end
  end
end
