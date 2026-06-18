module SaltEdge
  module Client
    def get(path, headers: {}, data: {})
       raise NotImplementedError
    end

    def post(path, headers: {}, data: {})
       raise NotImplementedError
    end

    def build_url(path)
       raise NotImplementedError
    end
  end
end

ClientService.include(Client)
LoggingClientService.include(Client)
