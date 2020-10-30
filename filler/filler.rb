# Tiny class handling all the variables
class Filler

    # init values
    def initialize values, delay, qr, templates="./filler/templates"
        # get current time
        now = Time.now

        # translation from english to french
        @translate = Hash["work" => "travail", "health" => "sante", "family" => "famille",
            "handicap" => "handicap", "justice" => "convocation",
            "missions" => "missions", "transits" => "transits",
            "pets" => "animaux"]

        values["LMO_REASON"] = @translate[values["LMO_REASON"]]

        # map values fetch from env or cli
        @values = values

        # templates
        @qr = File.read("#{templates}/qrcode.erb")
        @text = File.read("#{templates}/attestation.erb")

        # handle delay if specified
        if delay != nil then
            time = now + delay*60
        else
            time = now
        end

        # dedicated attribute
        @date = time.strftime("%d/%m/%Y")
        @time = time.strftime("%H:%M")
    end

    # generate string
    def fill
        ERB.new(@text).result(binding)
    end

    def fill_qr
        ERB.new(@qr).result(binding)
    end

end
