# frozen_string_literal: true

# SnapshotHelper
module SnapshotHelper
  # @return [String]
  OUTPUT_DIR = File.expand_path('../snapshots', __dir__)

  # @param file_name [String]
  # @param string []
  # @return [void]
  def write_snapshot(file_name, string)
    File.write(File.join(OUTPUT_DIR, file_name), string)
  end
end
