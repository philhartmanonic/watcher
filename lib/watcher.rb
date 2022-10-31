require_relative 'extra_class_features'

class Watcher
  def initialize(ci=0)
    @ci = ci # ci stands for "current index" - it's to help with tracking progress across multiple threads
  end

  def fill_bar(pct, space, str="", fill_color=:bg_black, empty_color=:bg_white)
    filled = (space * pct).round(0)
    empty = (space - filled)
    parts = []
    if empty - 10 >= str
      parts = ["", "     #{str}"]
    else
      parts = ["#{str}     ", ""]
    end
    parts[0] = parts[0].rjust(filled).public_send(fill_color).paired
    parts[1] = parts[1].ljust(empty).public_send(empty_color).paired
    parts.join
  end

  def estimate_remaining(pct, seconds_passsed)
    total_run_time = seconds_passed.to_f / pct
    (total_run_time - seconds_passed).print_time
  end

  def progress_bar(ci, tc, ts, message=nil)
    total_count_text = tc.commas
    seconds_passed = Time.now - ts
    pct_decimal = ci.to_f / tc
    front = "(#{[seconds_passed.print_time, message].select{ |x| x.to_s.strip.length > 0 }.join('|')})  #{ci.commas.rjust(total_count_text.length)} / #{total_count_text}  - #{pct_decimal.print_percent}  ||["
    bar = fill_bar(pct_decimal, (TERM_WIDTH - (front.length + 3)), "estimated remaining: #{estimate_remaining(pct_decimal, seconds_passed)}")
    print "\r#{" " * TERM_WIDTH}\r#{front}#{bar}]||"
  end

  def a(i=1)
    @ci += i
  end

  def track(tc, reset=true, message=nil)
    ts = Time.now
    @ci = (reset ? 0 : @ci)
    worker = Thread.new do
      yield
    end

    tracker = Thread.new do
      while worker.alive?
        sleep 1
        progress_bar(@ci, tc, ts, message)
      end
      puts
    end

    [worker, tracker].each(&:join)
  end

  def track_fast(arr_of_whatevers, thread_count=20, reset=true, message=nil)
    tc = arr_of_whatevers.count
    ts = Time.now
    items_per_thread = (tc.to_f / thread_count).ceil
    @ci = reset ? 0 : @ci
    workers = arr_of_whatevers.each_slice(items_per_thread).to_a.map do |group_of_whatevers|
      group_of_whatevers.each do |whatever|
        @ci += 1
        yielfd whatever
      end
    end

    tracker = Thread.new do
      while workers.any?(&:alive?)
        sleep 1
        progress_bar(@ci, tc, ts, message)
      end
    end

    (workers + [tracker]).each(&:join)
  end
end
