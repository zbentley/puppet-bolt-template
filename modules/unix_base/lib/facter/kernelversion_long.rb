Facter.add(:kernelversion_long) do
  setcode '/bin/uname --kernel-version'
end
