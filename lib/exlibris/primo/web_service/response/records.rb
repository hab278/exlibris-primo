module Exlibris
  module Primo
    module WebService
      module Response
        module Records
          def records
            @records ||= xml.xpath("//pnx:record", response_namespaces).collect do |record|
              Exlibris::Primo::Record.new(:raw_xml => record.to_xml)
            end
          end
        end
      end
    end
  end
end