package com.team.dtd.entity;

import com.team.dtd.enums.StageType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "stages")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Stage {

    @Id
    private Integer idx;

    @Enumerated(EnumType.STRING)
    @Column(name = "stage_type", nullable = false)
    private StageType stageType;

    @Column(name = "stage_name", nullable = false, length = 100)
    private String stageName;

    // JSON 데이터는 String으로 받아서 처리하거나 별도 컨버터 사용
    @Column(name = "rewards_json", columnDefinition = "LONGTEXT")
    private String rewardsJson;

    @Column(name = "map_config_json", columnDefinition = "LONGTEXT")
    private String mapConfigJson;
}