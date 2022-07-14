Facter.add(:osx_sdkroot) do
  setcode 'xcrun --show-sdk-path'
end
