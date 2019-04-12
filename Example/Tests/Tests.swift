// https://github.com/Quick/Quick

import Quick
import Nimble
import Tsuchi

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("payload decode") {
            context("`aps` decode") {
                it("can decode only body field") {
                    let payload = #"{ "alert" : "Message received from Bob" }"#
                    expect(try? JSONDecoder().decode(APS.self, from: payload.data(using: .utf8)!)).toNot(beNil())
                }
                it("can decode body and more fields") {
                    let payload = #"""
                    {
                      "alert" : {
                        "title" : "Game Request",
                        "body" : "Bob wants to play poker",
                        "action-loc-key" : "PLAY"
                      },
                      "badge" : 5
                    }
                    """#
                    expect(try? JSONDecoder().decode(APS.self, from: payload.data(using: .utf8)!)).toNot(beNil())

                }
            }
        }
    }
}
