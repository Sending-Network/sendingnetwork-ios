Pod::Spec.new do |s|

  s.name         = "SDNSDK"
  s.version      = "0.1.0"
  s.summary      = "The iOS SDK to build apps compatible with SDN "

  s.description  = <<-DESC
				   SDN is a new open standard for interoperable Instant Messaging and VoIP, providing pragmatic HTTP APIs and open source reference implementations for creating and running your own real-time communication infrastructure.

				   Our hope is to make VoIP/IM as universal and interoperable as email.
                   DESC

  s.homepage     = "https://sending-network.gitbook.io/sending.network/overview/getting-started"

  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author             = { "sdn.org" => "support@sdn.org" }

  s.source       = { :git => "https://github.com/Sending-Network/sendingnetwork-ios.git", :tag => "v#{s.version}" }
  
  s.requires_arc  = true
  s.swift_versions = ['5.1', '5.2']
  
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  
  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
      ss.ios.deployment_target = "13.0"
      ss.osx.deployment_target = "10.15"
      
      ss.source_files = "SDNSDK", "SDNSDK/**/*.{h,m}", "SDNSDK/**/*.{swift}"
      ss.osx.exclude_files = "SDNSDK/VoIP/MXiOSAudioOutputRoute*.swift"
      ss.private_header_files = ['SDNSDK/SDNSDKSwiftHeader.h', "SDNSDK/**/*_Private.h"]
      ss.resources = "SDNSDK/**/*.{xcdatamodeld}"
      ss.frameworks = "CoreData"

      ss.dependency 'AFNetworking', '~> 4.0.0'
      ss.dependency 'GZIP', '~> 1.3.0'

      ss.dependency 'SwiftyBeaver', '1.9.5'

      # Requirements for e2e encryption
      ss.dependency 'OLMKit', '~> 3.2.5'
      ss.dependency 'Realm', '10.27.0'
      ss.dependency 'libbase58', '~> 0.1.4'
      ss.dependency 'MatrixSDKCrypto', '0.3.11', :configurations => ["DEBUG", "RELEASE"], :inhibit_warnings => true
  end

  s.subspec 'JingleCallStack' do |ss|
    ss.ios.deployment_target = "13.0"
    
    ss.source_files  = "SDNSDKExtensions/VoIP/Jingle/**/*.{h,m}"
    
    ss.dependency 'SDNSDK/Core'
    
    # The Google WebRTC stack
    # Note: it is disabled because its framework does not embed x86 build which
    # prevents us from submitting the SDNSDK pod
    #ss.ios.dependency 'GoogleWebRTC', '~>1.1.21820'
    
    # Use WebRTC framework included in Jitsi Meet SDK
    # Use the lite version so we don't add a dependency on Giphy.
    ss.ios.dependency 'JitsiMeetSDKLite', '8.1.2-lite'
  end

end
