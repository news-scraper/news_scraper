require 'readline'

module NewsScraper
  module CLI
    extend self

    DEFAULT_COLOR = "\x1b[36m".freeze

    def log(message, color: DEFAULT_COLOR, new_line: false)
      message += "\n" if new_line
      $stdout.puts "#{color}┃\x1b[0m " + message
    end

    def log_lines(message, color: DEFAULT_COLOR, new_line: false)
      message.split("\n").each do |line|
        log(line, color: color, new_line: new_line)
      end
    end

    def confirm(msg, color: DEFAULT_COLOR)
      print "#{color}┃\x1b[0m #{msg} (y/n) "
      $stdin.gets.chomp =~ /[Yy]/
    end

    def get_input(msg = nil)
      log(msg) if msg
      Readline.completion_append_character = " "
      Readline.completion_proc = nil
      result = begin
        Readline.readline("\x1b[34m┃ > \x1b[33m", true)
      rescue Interrupt
        nil
      end
      print "\e[0m" # reset colour
      result
    end

    def prompt_with_options(question, options)
      log(question)
      log("Your options are:")
      options.each_with_index(1) do |v, idx|
        log("#{idx}) #{v}")
      end
      log("Choose a number between 1 and #{options.length}")

      Readline.completion_append_character = " "
      Readline.completion_proc = nil

      buf = -1
      available = (1..options.length).to_a
      until available.include?(buf.to_i)
        begin
          buf = Readline.readline("\x1b[34m┃ > \x1b[33m", true)
        rescue Interrupt
          nil
        end

        if buf.nil?
          STDERR.puts
          next
        end

        buf = buf.chomp
        buf = -1 if buf.empty?
        buf = -1 if buf.to_i.to_s != buf
      end

      print "\e[0m" # reset colour
      options[buf.to_i - 1]
    end

    ## Fancy Headers and Footers

    def put_header(text = "", color = DEFAULT_COLOR)
      put_edge(color, "┏━━ ", text)
    end

    def put_footer(color = DEFAULT_COLOR)
      put_edge(color, "┗", "")
    end

    def put_edge(color, prefix, text)
      ptext = "#{color}#{prefix}#{text}"
      textwidth = printing_width(ptext)

      termwidth = IO.console ? IO.console.winsize[1] : 80
      termwidth = 30 if termwidth < 30

      if textwidth > termwidth
        ptext = ptext[0...termwidth]
        textwidth = termwidth
      end
      padwidth = termwidth - textwidth
      pad = "━" * padwidth
      formatted = "#{ptext}#{color}#{pad}\x1b[0m\n"

      $stdout.puts formatted
    end

    # ANSI escape sequences (like \x1b[31m) have zero width.
    # when calculating the padding width, we must exclude them.
    def printing_width(str)
      str.gsub(/\x1b\[[\d;]+[A-z]/, '').size
    end
  end
end
