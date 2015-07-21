class PriorityQueue
  def initialize
    @queues = { high: [], low: [] }
  end

  # Remove element from head of queue
  def dequeue
    [:high, :low].each do |priority|
      q = @queues[priority]
      return q.shift unless q.empty?
    end
    nil
  end

  # Add element to tail of queue
  def enqueue(priority, val)
    priority ||= :low
    unless [:high, :low].include?(priority)
      raise "Invalid priority #{priority}"
    end

    @queues[priority] << val
  end

  def to_s
    @queues.to_s
  end
end
