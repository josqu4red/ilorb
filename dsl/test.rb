require './command_generator'

@contexts = ["rib", "server", "user"]

HP::CG.commands "rib" do
  read_command "foo"

  write_command "bar" do
    attributes :a1 => "bim"
    elements :e1 => "zlam"
  end
end

HP::CG.commands "server" do
  read_command "fou"

  write_command "baz" do
    attributes :a1 => "bam"
    elements :e1 => "zim"
  end
end
