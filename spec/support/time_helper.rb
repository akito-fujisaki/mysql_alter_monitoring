# frozen_string_literal: true

# TimeHelper
module TimeHelper
  # @return [void]
  def freeze_time
    allow(Time).to receive(:now).and_return(Time.now)
  end
end
