module Puppet::Parser::Functions
  newfunction(:oc_replace) do |args|
    title = args[0]
    resource = args[1]
    changes = args[2]

    update = []
    condition = []

    changes.each do |key, value|
      case value
        when String
          update << "#{key} = \"#{value}\""
          condition << "#{key} == \"#{value}\""
        when Array
          update << "#{key} += #{value}"
          condition << "#{key} | contains(#{value})"
        else
          update << "#{key} = #{value}"
          condition << "#{key} == #{value}"
      end
    end

   update = update.join(' | ')
   condition = condition.join(' and ')

   function_info(["Update #{update}"])
   function_info(["Unless #{condition}"])

   function_create_resources(['exec', title => {
     'provider' => 'shell',
     'environment' => 'HOME=/root',
     'cwd'     => "/root",
     'command' => "oc get '#{resource}' -o json | jq '#{update}' | oc replace '#{resource}' -f -",
     'unless' => "oc get '#{resource}' -o json | [ `jq '#{condition}'` == true ]",
     'timeout' => 600,
   }])
  end
end
