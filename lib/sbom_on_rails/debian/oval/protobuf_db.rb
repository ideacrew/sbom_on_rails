require 'google/protobuf'

module SbomOnRails
  module Oval
    module ProtobufDb
      descriptor_data = "\n\x16protobuf/oval_db.proto\"t\n\nOvalRecord\x12)\n\x07rawHash\x18\x01 \x03(\x0b\x32\x18.OvalRecord.RawHashEntry\x1a;\n\x0cRawHashEntry\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\x1a\n\x05value\x18\x02 \x01(\x0b\x32\x0b.VersionSet:\x02\x38\x01\",\n\nVersionSet\x12\x1e\n\x08versions\x18\x01 \x03(\x0b\x32\x0c.VersionData\"\x88\x01\n\x0bVersionData\x12\x12\n\nversion_op\x18\x01 \x02(\t\x12\x0f\n\x07version\x18\x02 \x02(\t\x12\x16\n\x0etarget_version\x18\x03 \x02(\t\x12\r\n\x05title\x18\x04 \x02(\t\x12\x13\n\x0b\x64\x65scription\x18\x05 \x02(\t\x12\n\n\x02id\x18\x06 \x01(\t\x12\x0c\n\x04\x64\x61ta\x18\x07 \x01(\t"

      pool = Google::Protobuf::DescriptorPool.generated_pool
      pool.add_serialized_file(descriptor_data)

      OvalRecord = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("OvalRecord").msgclass
      VersionSet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("VersionSet").msgclass
      VersionData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("VersionData").msgclass
    end
  end
end