describe Evva::AndroidGenerator do
  let(:generator) { described_class.new }

  describe '#events' do
    subject { generator.events(events, "MixpanelAnalytics") }

    let(:events) { [
      Evva::MixpanelEvent.new('cp_page_view'),
      Evva::MixpanelEvent.new('cp_page_view_a', { course_id: 'Long', course_name: 'String' }),
      Evva::MixpanelEvent.new('cp_page_view_b', { course_id: 'Long', course_name: 'String', from_screen: 'CourseProfileSource' }),
      Evva::MixpanelEvent.new('cp_page_view_c', { course_id: 'Long', course_name: 'String', from_screen: 'CourseProfileSource?' }),
      Evva::MixpanelEvent.new('cp_page_view_d', { course_id: 'Long?', course_name: 'String' })
    ] }

    let(:expected) {
<<-Kotlin
package com.hole19golf.hole19.analytics

import com.hole19golf.hole19.analytics.Event
import com.hole19golf.hole19.analytics.MixpanelAnalyticsMask
import org.json.JSONObject

open class MixpanelAnalytics(private val mask: MixpanelAnalyticsMask) {

    open fun trackCpPageView() {
        mask.trackEvent(MixpanelEvent.CP_PAGE_VIEW)
    }

    open fun trackCpPageViewA(course_id: Long, course_name: String) {
        val properties = JSONObject().apply {
            put("course_id", course_id)
            put("course_name", course_name)
        }
        mask.trackEvent(MixpanelEvent.CP_PAGE_VIEW_A, properties)
    }

    open fun trackCpPageViewB(course_id: Long, course_name: String, from_screen: CourseProfileSource) {
        val properties = JSONObject().apply {
            put("course_id", course_id)
            put("course_name", course_name)
            put("from_screen", from_screen.key)
        }
        mask.trackEvent(MixpanelEvent.CP_PAGE_VIEW_B, properties)
    }

    open fun trackCpPageViewC(course_id: Long, course_name: String, from_screen: CourseProfileSource?) {
        val properties = JSONObject().apply {
            put("course_id", course_id)
            put("course_name", course_name)
            from_screen?.let { put("from_screen", it.key) }
        }
        mask.trackEvent(MixpanelEvent.CP_PAGE_VIEW_C, properties)
    }

    open fun trackCpPageViewD(course_id: Long?, course_name: String) {
        val properties = JSONObject().apply {
            course_id?.let { put("course_id", it) }
            put("course_name", course_name)
        }
        mask.trackEvent(MixpanelEvent.CP_PAGE_VIEW_D, properties)
    }

    open fun updateProperties(property: MixpanelProperties, value: Any) {
        mask.updateProperties(property.key, value)
    }

    open fun incrementCounter(property: MixpanelProperties) {
        mask.incrementCounter(property.key)
    }
}
Kotlin
    }

    it { should eq expected }
  end

  describe '#special_property_enums' do
    subject { generator.special_property_enums(enums) }
    let(:enums) { [
      Evva::MixpanelEnum.new('CourseProfileSource', ['course_discovery', 'synced_courses']),
      Evva::MixpanelEnum.new('PremiumFrom', ['Course Profile', 'Round Setup'])
    ] }
    let(:expected) {
<<-Kotlin
package com.hole19golf.hole19.analytics

enum class CourseProfileSource(val key: String) {
    COURSE_DISCOVERY("course_discovery"),
    SYNCED_COURSES("synced_courses");
}

enum class PremiumFrom(val key: String) {
    COURSE_PROFILE("Course Profile"),
    ROUND_SETUP("Round Setup");
}
Kotlin
     }
    it { should eq expected }
  end

  describe '#event_enum' do
    subject { generator.event_enum(event_bundle, 'MixpanelEvent') }
    let(:event_bundle) { [
      Evva::MixpanelEvent.new('nav_feed_tap', {}),
      Evva::MixpanelEvent.new('nav_performance_tap', {})
      ] }
    let(:expected) {
<<-Kotlin
package com.hole19golf.hole19.analytics

import com.hole19golf.hole19.analytics.Event

enum class MixpanelEvent(override val key: String) : Event {
    NAV_FEED_TAP("nav_feed_tap"),
    NAV_PERFORMANCE_TAP("nav_performance_tap");
}
Kotlin
     }
    it { should eq expected }
  end

  describe '#people_properties' do
    subject { generator.people_properties(people_bundle, 'MixpanelProperties') }
    let(:people_bundle) { ['rounds_with_wear', 'friends_from_facebook'] }
    let(:expected) {
<<-Kotlin
package com.hole19golf.hole19.analytics

enum class MixpanelProperties(val key: String) {
    ROUNDS_WITH_WEAR("rounds_with_wear"),
    FRIENDS_FROM_FACEBOOK("friends_from_facebook");
}
Kotlin
    }
    it { should eq expected }
  end
end
